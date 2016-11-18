from __future__ import print_function, unicode_literals, division, absolute_import

import mako.template
import faulthandler
import numpy as np
import os
import functools
import logging
import io

import nefis.cnefis

faulthandler.enable()

logger = logging.getLogger(__name__)

MAXDIMS = 5
MAXGROUPS = 100
MAXELEMENTS = 1000
DTYPES = {
    'REAL': np.float32,
    'INTEGER': np.int32,
    'CHARACTE': bytes
}


dump_tmpl = """
NEFIS FILE
% for var in variables:
${var}
 - attributes: ${variables[var].attributes}
 - type:  ${variables[var].dtype}
 - shape:  ${variables[var].shape}
% endfor

"""


class NefisException(Exception):
    """A nefis exception"""
    def __init__(self, message, status):
        super(Exception, self).__init__(message)
        self.status = status


class Dimension(object):
    def __init__(self, group, name, size):
        self.group = group
        self.name = name
        self.size = size


class Variable(object):
    def __init__(self, group, name, dtype, shape=(), attributes=None):
        self.group = group
        self.name = name
        self.dtype = dtype
        self.shape = shape
        self.attributes = attributes


def wrap_error(func):
    """wrap a nefis function to raise an error"""
    @functools.wraps(func)
    def wrapped(*args, **kwargs):
        result = func(*args, **kwargs)
        if isinstance(result, tuple):
            if len(result) == 1:
                error, result = result[0], None
            elif len(result) == 2:
                error, result = result[0], result[1]
            elif len(result) > 2:
                error, result = result[0], result[1:]

        else:
            error = result
        if error != 0:
            status, message = nefis.cnefis.neferr()
            raise NefisException(message, status)
        return result
    return wrapped


class Nefis(object):
    """Nefis file"""
    def __init__(self, def_file, ac_type=b'r', coding=b' '):
        """dat file is expected to be named .dat instead of .def"""

        self.def_file = def_file
        self.dat_file = def_file.replace('.def', '.dat')
        assert os.path.exists(self.def_file)
        assert os.path.exists(self.dat_file)
        logger.debug("Opening files: '%s' as def and '%s' as dat",
                     self.def_file, self.dat_file)
        filehandle = wrap_error(nefis.cnefis.crenef)(
            self.dat_file,
            self.def_file,
            coding,
            ac_type
        )
        self.filehandle = filehandle

    def close(self):
        wrap_error(nefis.cnefis.clsnef)(self.filehandle)


    @property
    def variables(self):
        elements = {}
        cells = {}

        for el in self.iter_elements():
            elements[el["name"]] = el
        for cell in self.iter_cells():
            cells[cell["name"]] = cell

        variables = {}
        for el in elements.values():
            cell = cells[el["name"]]
            variable = Variable(
                group=cell["group"],
                name=cell["name"],
                dtype=el["dtype"],
                shape=el["shape"],
                attributes=el["attributes"]
            )
            variables[variable.name] = variable
        return variables

    def iter_dat_groups(self):
        """loop over all the groups in the dat file"""

        grp_dimensions = np.zeros(MAXDIMS, dtype='int32')
        grp_order = np.zeros(MAXDIMS, dtype='int32')

        # yield the first group
        try:
            group_dat, group_def = wrap_error(nefis.cnefis.inqfst)(self.filehandle)
            yield group_dat, group_def
        except NefisException:
            raise StopIteration()
        # and yield the following groups
        # I don't like while loops so I defined a maximum number of groups
        for i in range(MAXGROUPS):
            try:
                group_dat, group_def = wrap_error(nefis.cnefis.inqnxt)(
                    self.filehandle
                )
                yield group_dat, group_def
            except NefisException:
                raise StopIteration()

    def iter_def_groups(self):
        """loop over all the groups in the def file"""

        try:
            result = wrap_error(nefis.cnefis.inqfgr)(self.filehandle)
            yield result
        except NefisException:
            raise StopIteration()

        # I don't like while loops so I defined a maximum number of groups
        for i in range(MAXGROUPS):
            try:
                result = wrap_error(nefis.cnefis.inqngr)(self.filehandle)
                yield result
            except NefisException:
                raise StopIteration()

        # empty generator

    def iter_cells(self):
        """loop over all the groups in the def file"""

        try:
            result = wrap_error(nefis.cnefis.inqfcl)(self.filehandle)
            name, n_cells, size, cell_names = result
            for cell_name in cell_names:
                yield dict(
                    group=name,
                    size=size,
                    name=cell_name
                )

        except NefisException:
            raise StopIteration()

        for i in range(MAXGROUPS):
            try:
                name, n_cells, size, cell_names = wrap_error(nefis.cnefis.inqncl)(self.filehandle)
                for cell_name in cell_names:
                    yield dict(
                        group=name,
                        size=size,
                        name=cell_name
                    )
            except NefisException:
                raise StopIteration()

    def iter_elements(self):
        """loop over all the elements in the def file"""
        def result2record(result):
            type2type = {
                "INTEGER": "int32",
                "REAL": "float32",
                "CHARACTE": "string"
            }
            (
                elm_name,
                type,
                quantity,
                unit,
                description,
                single_bytes,
                bytes,
                count,
                el_dimensions
            ) = result
            print(result)
            info = dict(
                name=elm_name,
                attributes=dict(
                    units=unit,
                    description=description,
                    quantity=quantity
                ),
                dtype=type2type[type],
                quantity=quantity,
                shape=el_dimensions
            )
            return info

        try:
            result = wrap_error(nefis.cnefis.inqfel)(self.filehandle)
            yield result2record(result)
        except NefisException:
            raise StopIteration()

        # I don't like while loops so I defined a maximum number of groups
        for i in range(MAXELEMENTS):
            try:
                result = wrap_error(nefis.cnefis.inqnel)(self.filehandle)
                yield result2record(result)
            except NefisException:
                raise StopIteration()

    def get_data(self, element, group, t=0):
        """return an array of data"""
        ntimes = wrap_error(nefis.cnefis.inqmxi)(self.filehandle, group)
        elm_dimensions = np.zeros(5, dtype='int32')
        result = wrap_error(nefis.cnefis.inqelm)(self.filehandle, element)
        (elm_type,
         elm_single_byte,
         elm_quantity,
         elm_unit,
         elm_description,
         elm_count,
         elm_dimensions) = result
        logger.info('got info: %s', result)

        usr_index = np.zeros((5, 3), dtype=np.int32)
        # first timestep:  0 -> 1 based
        usr_index[0, 0] = t + 1
        # last timestep:
        usr_index[0, 1] = t + 1
        # step
        usr_index[0, 2] = 1

        logger.info("elm_dimensions: %s", elm_dimensions)
        logger.info("elm_single_byte: %s", elm_single_byte)
        # number of bytes
        length = elm_single_byte
        # times number of timesteps
        length *= 1
        # times dimensions
        for dim in elm_dimensions:
            length *= dim
        usr_order = np.arange(1, 6, dtype=np.int32)
        # get the data (as buffer)
        buffer_res = wrap_error(nefis.cnefis.getelt)(
            self.filehandle,
            group,
            element,
            usr_index,
            usr_order,
            length
        )
        # lookup data type
        dtype = DTYPES[elm_type.strip()]
        if dtype is bytes:
            # return bytes
            return buffer_res.rstrip()
        # convert to typed array
        data = np.fromstring(buffer_res, dtype=dtype)
        # return shaped array
        return data.reshape(elm_dimensions[::-1])

    def dump(self):
        """Create a dump of the file"""

        stream = io.StringIO()
        stream.write('NEFIS DUMP\n')
        stream.write('='*50 + '\n')
        stream.write('GROUPS\n')
        for group_dat, group_def in self.iter_dat_groups():
            stream.write("%s => %s\n" % (group_dat, group_def))
        stream.write('GROUP DEFINTIONS\n')
        for record in self.iter_def_groups():
            stream.write("%s\n" % (record,))
        stream.write('CELLS\n')
        for record in self.iter_cells():
            stream.write("%s\n" % (record,))
        stream.write('ELEMENTS\n')
        for record in self.iter_elements():
            stream.write("%s\n" % (record,))
        return stream.getvalue()

    def dump2(self):
        tmpl = mako.template.Template(dump_tmpl)
        text = tmpl.render(variables=self.variables)
        return text
