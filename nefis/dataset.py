from __future__ import print_function, unicode_literals, division, absolute_import

import mako.template
import faulthandler
import numpy as np
import os
import functools
import logging
import io
import json

import bokeh.core.json_encoder
import nefis.cnefis

faulthandler.enable()

logger = logging.getLogger(__name__)

MAXDIMS = 5
MAXGROUPS = 100
MAXELEMENTS = 1000

dump_tmpl = """
nefis ${ds.def_file} {
variables:
% for group in groups.values():
    group: ${group['name']}
%  for variable in variables.values():
        ${variable.dtype} ${variable.name}${tuple(variable.shape)} ;
%   for attr, val in variable.attributes.items():
            ${variable.name}:${attr} = ${repr(val)}
%   endfor
%  endfor
% endfor

"""
# dimensions:
# % for dimension in dimensions:
#   ${dimension['name']} = ${len(dimension)} ;
# % endfor


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
        self._ds = None

    def __getitem__(self, s=None):
        if s == slice(None):
            t = 0
        else:
            t = s
        data = self._ds.get_data(self.group, self.name, t=t)
        return data

    def flat(self):
        """return a flat object that can be used to serialize the metadata of the variable"""
        return dict(
            name=self.name,
            dtype=self.dtype,
            shape=self.shape,
            attributes=self.attributes
        )


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


class NefisJSONEncoder(bokeh.core.json_encoder.BokehJSONEncoder):
    def default(self, obj):
        if isinstance(obj, Variable):
            return obj.flat()
        # Let the base class default method raise the TypeError
        return bokeh.core.json_encoder.BokehJSONEncoder.default(self, obj)


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
    def groups(self):
        groups = {}
        def2dat = {}
        for group_dat, group_def in self.iter_dat_groups():
            def2dat[group_def] = group_dat
        for record in self.iter_def_groups():
            record["name_dat"] = def2dat[record["name"]]
            groups[record["name"]] = record
        return groups

    @property
    def cells(self):
        cells = {}
        for record in self.iter_cells():
            cells[record["name"]] = record
        return cells

    @property
    def variables(self):
        elements = {}
        cells = self.cells

        for el in self.iter_elements():
            elements[el["name"]] = el
        for cell in self.cells.values():
            cells[cell["name"]] = cell

        variables = {}
        for cell in cells.values():
            for name in cell["variables"]:
                el = elements[name]
                variable = Variable(
                    group=cell["name"],
                    name=el["name"],
                    dtype=el["dtype"],
                    shape=el["shape"],
                    attributes=el["attributes"]
                )
                variable._ds = self
                variables[variable.name] = variable
        return variables

    def iter_dat_groups(self):
        """loop over all the groups in the dat file"""

        grp_dimensions = np.zeros(MAXDIMS, dtype='int32')
        grp_order = np.zeros(MAXDIMS, dtype='int32')

        # yield the first group
        try:
            group_dat, group_def = wrap_error(nefis.cnefis.inqfst)(self.filehandle)
            logger.debug("first dat group %s %s", group_dat, group_def)
            yield group_dat, group_def
        except NefisException as e:
            logger.debug("no first dat group", exc_info=True)
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
            (
                group_name,
                cel_name,
                size,
                shape,
                order
            ) = result
            record = dict(
                name=group_name,
                cell=cel_name,
                size=size,
                shape=shape,
                order=order
            )
            result = wrap_error(nefis.cnefis.inqmxi)(self.filehandle, group_name)
            record["group_size"] = result
            yield record
        except NefisException:
            logger.debug("no first def group", exc_info=True)
            raise StopIteration()

        # I don't like while loops so I defined a maximum number of groups
        for i in range(MAXGROUPS):
            try:
                result = wrap_error(nefis.cnefis.inqngr)(self.filehandle)
                (
                    group_name,
                    cel_name,
                    size,
                    shape,
                    order
                ) = result
                record = dict(
                    name=group_name,
                    cell=cel_name,
                    size=size,
                    shape=shape,
                    order=order
                )
                result = wrap_error(nefis.cnefis.inqmxi)(self.filehandle, group_name)
                record["group_size"] = result
                yield record
            except NefisException:
                raise StopIteration()

        # empty generator

    def iter_cells(self):
        """loop over all the groups in the def file"""

        try:
            result = wrap_error(nefis.cnefis.inqfcl)(self.filehandle)
            cell_name, n_cells, size, variable_names = result
            yield dict(
                name=cell_name,
                size=size,
                variables=variable_names
            )

        except NefisException:
            raise StopIteration()

        for i in range(MAXGROUPS):
            try:
                result = wrap_error(nefis.cnefis.inqncl)(self.filehandle)
                cell_name, n_cells, size, variable_names = result
                yield dict(
                    name=cell_name,
                    size=size,
                    variables=variable_names
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

    def get_data(self, group, element, t=0):
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
        datatype = elm_type.strip().upper()
        if datatype == 'CHARACTE':
            dtype = bytes
        elif datatype == 'REAL':
            if elm_single_byte == 4:
                dtype = np.float32
            elif elm_single_byte == 8:
                dtype = np.float64
        elif datatype == 'INTEGER':
            if elm_single_byte == 4:
                dtype = np.int32
            elif elm_single_byte == 8:
                dtype = np.int64
        else:
            raise ValueError('Invalid Datatype: {} {}'.format(elm_type.strio(), elm_single_byte))
        if dtype is bytes:
            # return bytes
            return buffer_res.rstrip()
        # convert to typed array
        data = np.fromstring(buffer_res, dtype=dtype)
        # return shaped array
        print(data)
        return data.reshape(elm_dimensions[::-1])

    def dump_json(self):
        """Create a dump of the file"""

        groups = self.groups
        cells = self.cells
        variables = self.variables

        for group in groups.values():
            # replace cell name by cell object
            group["cell"] = cells[group["cell"]]
            cell = group["cell"]
            variable_list = []
            for name in cell["variables"]:
                variable_list.append(variables[name])
            cell["variables"] = variable_list

        return json.dumps({"groups": groups}, cls=NefisJSONEncoder, indent=2)

    def dump_ncdump(self):
        """Dump in a format similar to ncdump"""
        tmpl = mako.template.Template(dump_tmpl)
        text = tmpl.render(ds=self, variables=self.variables, groups=self.groups)
        return text
