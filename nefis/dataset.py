from __future__ import print_function, unicode_literals, division, absolute_import

import numpy as np
import os
import functools
import logging
import io

import nefis.cnefis


logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

MAXDIMS = 5
MAXGROUPS = 100
MAXELEMENTS = 1000
DTYPES = {
    'REAL': np.float32,
    'INTEGER': np.int32,
    'CHARACTE': bytes
}


class NefisException(Exception):
    """A nefis exception"""
    def __init__(self, message, status):
        super(Exception, self).__init__(message)
        self.status = status


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
        version = wrap_error(nefis.cnefis.getnfv)()
        logger.info("version: %s", version)

        self.def_file = def_file.encode()
        self.dat_file = def_file.replace('.def', '.dat').encode()
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

        # try:
        #     result = wrap_error(nefis.cnefis.inqfgr)(self.filehandle)
        #     yield result
        # except NefisException:
        #     raise StopIteration()

        # I don't like while loops so I defined a maximum number of groups
        # for i in range(MAXGROUPS):
        #     try:
        #         result = wrap_error(nefis.cnefis.inqngr)(self.filehandle)
        #         yield result
        #     except NefisException:
        #         raise StopIteration()

        # empty generator
        return
        yield


    def iter_def_cells(self):
        """loop over all the groups in the def file"""

        try:
            result = wrap_error(nefis.cnefis.inqfcl)(self.filehandle)
            name, n_cells, size, cell_names = result
            yield from cell_names
        except NefisException:
            raise StopIteration()

        for i in range(MAXGROUPS):
            try:
                result = wrap_error(nefis.cnefis.inqncl)(self.filehandle)
                yield result
            except NefisException:
                raise StopIteration()

    def iter_def_elems(self):
        """loop over all the elements in the def file"""

        # try:
        #     result = wrap_error(nefis.cnefis.inqfel)(self.filehandle)
        #     yield result
        # except NefisException:
        #     raise StopIteration()

        # I don't like while loops so I defined a maximum number of groups
        # for i in range(MAXELEMENTS):
        #     try:
        #         result = wrap_error(nefis.cnefis.inqnel)(self.filehandle)
        #         yield result
        #     except NefisException:
        #         raise StopIteration()
        return
        yield

    def get_data(self, element, group, t=0):
        """return an array of data"""
        ntimes = wrap_error(nefis.cnefis.inqmxi)(self.filehandle, group)
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
        for group_dat, group_def in self.iter_dat_groups():
            stream.write("%s => %s\n" % (group_dat, group_def))
        # for record in self.iter_def_groups():
        #     stream.write("%s\n" % (record,))
        for record in self.iter_def_cells():
            stream.write("%s\n" % (record,))
        # for record in self.iter_def_elems():
        #     stream.write("%s\n" % (record,))
        return stream.getvalue()
