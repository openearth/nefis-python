import numpy as np
cimport numpy as np
import ctypes
import itertools

cdef extern:
    int Clsnef (int * )
    int Credat (int * , char * , char * )
    int Crenef (int * , char * , char * ,  char, char)
    int Defcel3(int * , char * , int, char * )
    int Defelm (int * , char * , char * , int  , char * , char * , char * , int  , int * )
    int Defgrp (int * , char * , char * , int  , int * , int * )
    int Flsdat (int * )
    int Flsdef (int * )
    int Getels (int * , char * , char * , int * , int * , int * , void *  )
    int Getelt (int * , char * , char * , int * , int * , int * , void *  )
    int Gethdf (int * , char *  )
    int Gethdt (int * , char *  )
    int Getiat (int *, char * , char * , int * )
    int Getnfv (char ** )
    int Getrat (int *, char * , char * , float * )
    int Getsat (int *, char * , char * , char * )
    int Inqcel3(int *, char * , int * , char * )
    int Inqdat (int *, char * , char *  )
    int Inqelm (int *, char * , char * , int * , char * , char * , char * , int * , int * )
    int Inqfcl3(int * , char * , int * , int * , char ** )
    int Inqfel (int * , char * , char * , char * , char * , char * , int * , int * , int * , int * )
    int Inqfgr (int *, char * , char * , int * , int * , int * )
    int Inqfia (int *, char * , char * , int * )
    int Inqfra (int *, char * , char * , float * )
    int Inqfsa (int * , char * , char * , char *  )
    int Inqfst (int *, char * , char *  )
    int Inqgrp (int *, char * , char * , int * , int * , int * )
    int Inqmxi (int * , char * , int * )
    int Inqncl3(int * , char * , int * , int * , char ** )
    int Inqnel (int * , char * , char * , char * , char * , char * , int * , int * , int * , int * )
    int Inqngr (int *, char * , char * , int * , int * , int * )
    int Inqnia (int *, char * , char * , int * )
    int Inqnra (int *, char * , char * , float * )
    int Inqnsa (int *, char * , char * , char *  )
    int Inqnxt (int *, char * , char *  )
    int Neferr (int, char *)
    int Putels (int *, char * , char * , int * , int * , void * )
    int Putelt (int *, char * , char * , int * , int * , void * )
    int Putiat (int *, char * , char * , int * )
    int Putrat (int *, char * , char * , float * )
    int Putsat (int *, char * , char * , char * )
#-------------------------------------------------------------------------


def clsnef(fd):
    """
    Close the NEFIS files (data and definition file)
    Keyword arguments:
        integer -- NEFIS file number
    Return value:
        integer -- error number
    """
    cdef int c_fd

    c_fd = fd

    status = Clsnef(& c_fd)

    return status
#-------------------------------------------------------------------------


def credat(fd, grp_name, grp_defined):
    """
    Create a data group on the NEFIS file
    Keyword arguments:
        integer -- NEFIS file number
        string  -- grp_name
        string  -- grp_defined
    Return value:
        integer -- error number
    """
    cdef int   c_fd

    c_fd = fd

    status = Credat(& c_fd, grp_name, grp_defined)

    return status
#-------------------------------------------------------------------------


def crenef(a, b, c, d):
    """
    Create or open NEFIS files
    Keyword arguments:
        string  -- data file name
        string  -- definition file name
        string  -- coding
        string  -- access type
    Return value:
        integer -- error number
    """
    cdef int c_fd

    c_fd = -1

    status = Crenef(& c_fd, a, b, ord(c), ord(d))

    return status, c_fd
#-------------------------------------------------------------------------


def defcel(fd, cl_name, el_names_count, el_names):
    """
    Define a cell on the NEFIS file
    Keyword arguments:
        integer -- NEFIS file number
        string  -- cel_name
        integer -- number of element names
        string  -- list of element names
    Return value:
        integer -- error number
    """
    cdef int    c_fd
    cdef int    c_elm_names_count
    cdef char * c_elm_names
    cdef int    status

    c_fd = fd
    c_elm_names_count = el_names_count

    elm_names = bytearray(20) * 17 * el_names_count
    for i in range(el_names_count):
        elm_names[17 * i:17 * (i + 1)] = el_names[i]
    c_elm_names = elm_names
    status = Defcel3(& c_fd, cl_name, c_elm_names_count, c_elm_names)
    return status
#-------------------------------------------------------------------------


def defelm(fd, el_name, el_type, el_single_byte, el_quantity, el_unit, el_desc, el_dim_count, np.ndarray[int, ndim=1, mode="c"] el_dimensions):
    """
    Define an element on the NEFIS file
    Keyword arguments:
        integer -- NEFIS file number
        string  -- element name
        string  -- element type
        integer -- number of bytes for a single element
        string  -- element quantity
        string  -- element unit
        string  -- element description
        integer -- number of dimensions
        integer -- array with dimension of element
    Return value:
        integer -- error number
    """
    cdef int   c_fd
    cdef int   c_elm_single_byte
    cdef int   c_elm_dim_count
    cdef int * c_elm_dimensions
    cdef int   status

    c_fd = fd
    c_elm_single_byte = el_single_byte
    c_elm_dim_count = el_dim_count
    c_elm_dimensions = &el_dimensions[0]

    status = Defelm(& c_fd, el_name, el_type, c_elm_single_byte, el_quantity, el_unit, el_desc, c_elm_dim_count, c_elm_dimensions)

    return status
#-------------------------------------------------------------------------


def defgrp(fd, gr_name, cl_name, gr_dim_count, np.ndarray[int, ndim=1, mode="c"] gr_dimensions, np.ndarray[int, ndim=1, mode="c"] gr_order):
    """
    Define a group on the NEFIS file (definition part)
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name
        string  -- cel name
        integer -- number of dimensions
        integer -- array with dimension of group
        integer -- array defining the group order
    Return value:
        integer -- error number
    """
    cdef int   c_fd
    cdef int   c_grp_dim_count
    cdef int * c_grp_dimensions
    cdef int * c_grp_order
    cdef int   status

    c_fd = fd
    c_grp_dim_count = gr_dim_count
    c_grp_dimensions = &gr_dimensions[0]
    c_grp_order = &gr_order[0]

    status = Defgrp(& c_fd, gr_name, cl_name, c_grp_dim_count, c_grp_dimensions, c_grp_order)

    return status
#-------------------------------------------------------------------------


def flsdat(fd):
    """
    Force a flush of NEFIS (data part)
    Keyword arguments:
        integer -- NEFIS file number
    Return value:
        integer -- error number
    """
    cdef int c_fd
    cdef int status

    c_fd = fd

    status = Flsdat(& c_fd)

    return status
#-------------------------------------------------------------------------


def flsdef(fd):
    """
    Force a flush of NEFIS (definition part)
    Keyword arguments:
        integer -- NEFIS file number
    Return value:
        integer -- error number
    """
    cdef int c_fd
    cdef int status

    c_fd = fd

    status = Flsdef(& c_fd)

    return status
#-------------------------------------------------------------------------


def getels(fd, gr_name, el_name, np.ndarray[int, ndim=2, mode="c"] user_index, np.ndarray[int, ndim=1, mode="c"] user_order, buffer_length):
    """
    Get string element from NEFIS file
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name
        string  -- element name
        integer -- array user index (2d)
        integer -- array user order (1d)
        integer -- buffer length in bytes
    Return value:
        integer -- error number
        string  -- list of string elements
    """
    cdef int    c_fd
    cdef int    c_bl
    cdef int    status
    cdef char * c_buffer
    cdef int * c_user_index
    cdef int * c_user_order

    c_fd = fd
    c_bl = buffer_length
    c_user_index = &user_index[0, 0]
    c_user_order = &user_order[0]
    buf = chr(0) * (buffer_length+1)
    c_buffer = buf

    status = Getels( & c_fd, gr_name, el_name, c_user_index, c_user_order, & c_bl, c_buffer)
    for i in range(buffer_length):
        if c_buffer[i] == '\0':
            c_buffer[i] = ' '
    c_buffer[buffer_length] = '\0'

    return status, c_buffer
#-------------------------------------------------------------------------


def getelt(fd, gr_name, el_name, np.ndarray[int, ndim=2, mode="c"] user_index, np.ndarray[int, ndim=1, mode="c"] user_order, buffer_length):
    """
    Get alpha-numeric values from NEFIS file
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name
        string  -- element name
        integer -- array user index (2d)
        integer -- array user order (1d)
        integer -- buffer length in bytes
    Return value:
        integer -- error number
        string  -- list of element values
    """
    cdef int    c_fd
    cdef int    c_bl
    cdef int    status
    cdef char * c_buffer
    cdef int * c_user_index
    cdef int * c_user_order

    c_fd = fd
    c_bl = buffer_length
    c_user_index = &user_index[0, 0]
    c_user_order = &user_order[0]
    buf = chr(0) * (buffer_length+1)
    c_buffer = buf

    status = Getelt( & c_fd, gr_name, el_name, c_user_index, c_user_order, & c_bl, c_buffer)
    c_buffer[buffer_length] = '\0'
    buf = c_buffer[:buffer_length]

    return status, buf
#-------------------------------------------------------------------------


def gethdf(fd):
    """
    Get header of NEFIS file (definition part)
    Keyword arguments:
        integer -- NEFIS file number
    Return value:
        integer -- error number
        string  -- header of NEFIS file
    """
    cdef int    c_fd
    cdef char * c_buffer
    cdef int    status

    c_fd = fd
    buffer_length = 128 + 1
    buf = chr(20) * buffer_length
    c_buffer = buf
    status = Gethdf(& c_fd, c_buffer)
    c_buffer[buffer_length] = '\0'

    return status, c_buffer
#-------------------------------------------------------------------------


def gethdt(fd):
    """
    Get header of NEFIS file (data part)
    Keyword arguments:
        integer -- NEFIS file number
    Return value:
        integer -- error number
        string  -- header of NEFIS file
    """
    cdef int    c_fd
    cdef char * c_buffer
    cdef int    status

    c_fd = fd
    buffer_length = 128 + 1
    buf = chr(20) * buffer_length
    c_buffer = buf
    status = Gethdt(& c_fd, c_buffer)
    c_buffer[buffer_length] = '\0'

    return status, c_buffer
#-------------------------------------------------------------------------


def getiat(fd, grp_name, att_name):
    """
    Get integer attribute value
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name
        integer -- attribute name
    Return value:
        integer -- error number
        string  -- integer attribute value
    """
    cdef int c_fd
    cdef int c_buffer
    cdef int status

    c_fd = fd
    status = Getiat( & c_fd, grp_name, att_name, & c_buffer)

    return status, c_buffer
#-------------------------------------------------------------------------


def getnfv():
    """
    Get version of NEFIS library
    Keyword arguments:
        none
    Return value:
        integer -- error number
        string  -- NEFIS library version number
    """
    cdef char * c_buffer
    cdef int    status

    status = Getnfv(& c_buffer)

    return status, c_buffer
#-------------------------------------------------------------------------


def getrat(fd, grp_name, att_name):
    """
    Get float attribute value
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name
        string  -- attribute name
    Return value:
        integer -- error number
        float   -- float attribute value
    """
    cdef int   c_fd
    cdef float c_buffer
    cdef int   status

    c_fd = fd
    status = Getrat( & c_fd, grp_name, att_name, & c_buffer)

    return status, c_buffer
#-------------------------------------------------------------------------


def getsat(fd, grp_name, att_name):
    """
    Get string attribute value
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name
        string  -- attribute name
    Return value:
        integer -- error number
        string  -- string attribute value
    """
    cdef int    c_fd
    cdef char * c_buffer
    cdef int    status

    c_fd = fd
    buffer_length = 16
    buf = chr(20) * (buffer_length + 1)
    c_buffer = buf
    status = Getsat(& c_fd, grp_name, att_name, c_buffer)
    c_buffer[buffer_length] = '\0'

    return status, c_buffer
#-------------------------------------------------------------------------


def inqcel(fd, cl_name, el_names_count):
    """
    Inquire cel definition
    Keyword arguments:
        integer -- NEFIS file number
        string  -- cel name
        integer -- number of elements in cel
    Return value:
        integer -- error number
        integer -- actual number of elements in cel
        string  -- list of element names
    """
    cdef int     c_fd
    cdef int     c_elm_names_count
    cdef int     status
    cdef char ** names
    cdef char * c_elm_names

    buffer_length = 17 * el_names_count
    elm_names = chr(20) * buffer_length
    c_elm_names = elm_names

    c_fd = fd
    c_elm_names_count = el_names_count

    status = Inqcel3( & c_fd, cl_name, & c_elm_names_count, c_elm_names)
    el_names_count = c_elm_names_count

    for i in range(el_names_count):
        c_elm_names[17 * (i + 1) - 1] = ' '

    buffer_length = 17 * el_names_count
    c_elm_names[buffer_length] = '\0'

    return status, el_names_count, c_elm_names
#-------------------------------------------------------------------------


def inqdat(fd, grp_name):
    """
    Read corresponding group definition from the data group
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name
    Return value:
        integer -- error number
        string  -- group name as defined in definition file
    """
    cdef int    c_fd
    cdef int    status
    cdef char * c_buffer

    buffer_length = 17
    buf = chr(20) * buffer_length
    c_buffer = buf

    c_fd = fd

    status = Inqdat(& c_fd, grp_name, c_buffer)

    c_buffer[buffer_length] = '\0'

    return status, c_buffer
#-------------------------------------------------------------------------


def inqelm(fd, elm_name, np.ndarray[int, ndim=1, mode="c"] el_dimensions):
    """
    Inquire element definition
    Keyword arguments:
        integer -- NEFIS file number
        string  -- element name
        integer -- element dimensions
    Return value:
        integer -- error number
        string  -- type of element
        integer -- size in bytes of thia element
        string  -- quantity of element
        string  -- unit of element
        string  -- description of element
        integer -- actual number of element dimensions
    Return value via argument list
        integer -- actual element dimensions
    """
    cdef int    c_fd
    cdef int    status
    cdef char * c_type
    cdef int    c_single_bytes
    cdef char * c_quantity
    cdef char * c_unit
    cdef char * c_description
    cdef int    c_count
    cdef int *  c_dimensions

    buffer_length = 17
    buf1 = chr(20) * buffer_length
    c_type = buf1

    buf2 = chr(20) * buffer_length
    c_quantity = buf2

    buf3 = chr(20) * buffer_length
    c_unit = buf3

    buffer_length = 65
    buf4 = chr(20) * buffer_length
    c_description = buf4

    c_fd = fd
    elm_dimensions = np.arange(5).reshape(5)
    c_dimensions = &el_dimensions[0]

    status = Inqelm(& c_fd, elm_name, c_type, & c_single_bytes, c_quantity, c_unit, c_description, & c_count, c_dimensions)

    return status, c_type, c_single_bytes, c_quantity, c_unit, c_description, c_count
#-------------------------------------------------------------------------


def inqfcl(fd, el_names_count):
    """
    Inquire cel definition of the first cel
    Keyword arguments:
        integer -- NEFIS file number
        integer -- number of elements in cel
    Return value:
        integer -- error number
        string  -- cel name
        integer -- actual number of elements in cel
        integer -- size of cel in bytes
        string  -- list of element names
    """
    cdef int    c_fd
    cdef int    c_elm_names_count
    cdef int    c_bytes
    cdef int    status
    cdef char ** names
    cdef char * c_elm_names
    cdef char * c_cel_name

    c_fd = fd
    cel_name = bytearray(20) * 17
    c_cel_name = cel_name

    c_elm_names_count = el_names_count

    buffer_length = 17 * el_names_count
    elm_names = chr(20) * buffer_length
    c_elm_names = elm_names

    status = Inqfcl3(& c_fd, c_cel_name, & c_elm_names_count, & c_bytes, & c_elm_names)
    el_names_count = c_elm_names_count
    
    for i in range(el_names_count):
        c_elm_names[17 * (i + 1) - 1] = ' '
    
    buffer_length = 17 * el_names_count
    c_elm_names[buffer_length] = '\0'

    c_cel_name[17] = '\0'
    cel_name = c_cel_name
    
    return status, cel_name, el_names_count, c_bytes, c_elm_names
#-------------------------------------------------------------------------


def inqfel(fd, elm_count_dimensions, np.ndarray[int, ndim=1, mode="c"] el_dimensions):
    """
    Inquire element definition of the first element
    Keyword arguments:
        integer -- NEFIS file number
        integer -- number of dimensions
        integer -- element dimensions
    Return value:
        integer -- error number
        string  -- element name
        string  -- type of element
        integer -- size in bytes of thia element
        string  -- quantity of element
        string  -- unit of element
        string  -- description of element
        integer -- actual number of element dimensions
    Return value via argument list
        integer -- actual element dimensions
    """
    cdef int    c_fd
    cdef int    status
    cdef char * c_type
    cdef int    c_single_bytes
    cdef int    c_bytes
    cdef char * c_quantity
    cdef char * c_unit
    cdef char * c_description
    cdef int    c_count
    cdef int * c_dimensions

    elm_name = bytearray(20) * 17
    c_elm_name = elm_name

    buffer_length = 17
    buf1 = chr(20) * buffer_length
    c_type = buf1

    buf2 = chr(20) * buffer_length
    c_quantity = buf2

    buf3 = chr(20) * buffer_length
    c_unit = buf3

    buffer_length = 65
    buf4 = chr(20) * buffer_length
    c_description = buf4

    c_fd = fd
    elm_dimensions = np.arange(5).reshape(5)
    c_dimensions = &el_dimensions[0]

    c_count = elm_count_dimensions

    status = Inqfel( & c_fd, c_elm_name, c_type, c_quantity, c_unit, c_description, & c_single_bytes, & c_bytes, & c_count, c_dimensions)
    elm_size_bytes = c_bytes
    elm_count_dimensions = c_count

    c_elm_name[16] = '\0'
    elm_name = c_elm_name

    return status, elm_name, c_type, c_quantity, c_unit, c_description, c_single_bytes, elm_size_bytes, elm_count_dimensions
#-------------------------------------------------------------------------


def inqfgr(fd, gr_dim_count, np.ndarray[int, ndim=1, mode="c"] gr_dimensions, np.ndarray[int, ndim=1, mode="c"] gr_order):
    """
    Inquire group definition of the first group (definition part)
    Keyword arguments:
        integer -- NEFIS file number
        integer -- number of group dimensions
        integer -- group dimensions
        integer -- group order
    Return value:
        integer -- error number
        string  -- group name
        string  -- cel name
        integer -- actual number of group dimensions
    """
    cdef int   c_fd
    cdef int   c_grp_dim_count
    cdef int * c_grp_dimensions
    cdef int * c_grp_order
    cdef int   status
    cdef char * c_grp_name
    cdef char * c_cel_name

    c_fd = fd
    c_grp_dim_count = gr_dim_count
    c_grp_dimensions = &gr_dimensions[0]
    c_grp_order = &gr_order[0]

    buffer_length = 17
    buf1 = chr(20) * buffer_length
    c_grp_name = buf1

    buf2 = chr(20) * buffer_length
    c_cel_name = buf2

    status = Inqfgr( & c_fd, c_grp_name, c_cel_name, & c_grp_dim_count, c_grp_dimensions, c_grp_order)
    grp_name = c_grp_name
    cel_name = c_cel_name
    grp_dim_count = c_grp_dim_count

    return status, grp_name, c_cel_name, c_grp_dim_count
#-------------------------------------------------------------------------


def inqfia(fd, grp_name):
    """
    Inquire first integer attribute
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name
    Return value:
        integer -- error number
        string  -- attribute name
        string  -- attibute value
    """
    cdef int    c_fd
    cdef int    c_buffer
    cdef char * c_att_name
    cdef int    status

    c_fd = fd

    buffer_length = 17
    buf1 = chr(20) * buffer_length
    c_att_name = buf1

    status = Inqfia( & c_fd, grp_name, c_att_name, & c_buffer)

    return status, c_att_name, c_buffer
#-------------------------------------------------------------------------


def inqfra(fd, grp_name):
    """
    Inquire first float attribute
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name
    Return value:
        integer -- error number
        string  -- attribute name
        string  -- attibute value
    """
    cdef int    c_fd
    cdef float  c_buffer
    cdef char * c_att_name
    cdef int    status

    c_fd = fd

    buffer_length = 17
    buf1 = chr(20) * buffer_length
    c_att_name = buf1

    status = Inqfra( & c_fd, grp_name, c_att_name, & c_buffer)

    return status, c_att_name, c_buffer
#-------------------------------------------------------------------------


def inqfsa(fd, grp_name):
    """
    Inquire first string attribute
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name
    Return value:
        integer -- error number
        string  -- attribute name
        string  -- attibute value
    """
    cdef int    c_fd
    cdef char * c_att_value
    cdef char * c_att_name
    cdef int    status

    c_fd = fd

    buffer_length = 17
    buf1 = chr(20) * buffer_length
    c_att_name = buf1

    buf2 = chr(20) * buffer_length
    c_att_value = buf2

    status = Inqfsa(& c_fd, grp_name, c_att_name, c_att_value)

    return status, c_att_name, c_att_value[:16]
#-------------------------------------------------------------------------


def inqfst(fd):
    """
    Read corresponding group definition from the first data group
    Keyword arguments:
        integer -- NEFIS file number
    Return value:
        integer -- error number
        string  -- group name
        string  -- group name as on definition
    """
    cdef int    c_fd
    cdef char * c_grp_name
    cdef char * c_grp_defined
    cdef int    status

    c_fd = fd

    buffer_length = 17
    buf1 = chr(20) * buffer_length
    c_grp_name = buf1

    buf2 = chr(20) * buffer_length
    c_grp_defined = buf2

    status = Inqfst(& c_fd, c_grp_name, c_grp_defined)

    return status, c_grp_name[:16], c_grp_defined[:16]
#-------------------------------------------------------------------------


def inqgrp(fd, grp_defined, gr_dim_count, np.ndarray[int, ndim=1, mode="c"] gr_dimensions, np.ndarray[int, ndim=1, mode="c"] gr_order):
    """
    Inquire group definition
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name on definition
        integer -- number of group dimensions
        integer -- group dimensions
        integer -- group order
    Return value:
        integer -- error number
        string  -- cel name
        integer -- actual number of group dimensions
    """
    cdef int   c_fd
    cdef int   c_grp_dim_count
    cdef int * c_grp_dimensions
    cdef int * c_grp_order
    cdef int   status
    cdef char * c_grp_name
    cdef char * c_cel_name

    c_fd = fd
    c_grp_dim_count = gr_dim_count
    c_grp_dimensions = &gr_dimensions[0]
    c_grp_order = &gr_order[0]

    buffer_length = 17
    buf1 = chr(20) * buffer_length
    c_cel_name = buf1

    status = Inqfgr( & c_fd, grp_defined, c_cel_name, & c_grp_dim_count, c_grp_dimensions, c_grp_order)
    grp_dim_count = c_grp_dim_count

    return status, c_cel_name[:16], c_grp_dim_count
#-------------------------------------------------------------------------


def inqmxi(fd, grp_name):
    """
    Inquire maximum dimension of a group
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name
    Return value:
        integer -- error number
        integer -- maximum value of group dimensions
    """
    cdef int c_fd

    cdef int status
    cdef int c_buffer

    c_fd = fd

    status = Inqmxi( & c_fd, grp_name, & c_buffer)

    return status, c_buffer
#-------------------------------------------------------------------------


def inqncl(fd, el_names_count):
    """
    Inquire next cel
    Keyword arguments:
        integer -- NEFIS file number
        integer -- number of elements in cel
    Return value:
        integer -- error number
        string  -- cel name
        integer -- actual number of elements in cel
        integer -- size of cel in bytes
        string  -- list of element names
    """
    cdef int    c_fd
    cdef int    c_elm_names_count
    cdef int    c_bytes
    cdef int    status
    cdef char ** names
    cdef char * c_elm_names
    cdef char * c_cel_name

    c_fd = fd
    cel_name = bytearray(20) * 17
    c_cel_name = cel_name

    c_elm_names_count = el_names_count

    buffer_length = 17 * el_names_count
    elm_names = chr(20) * buffer_length
    c_elm_names = elm_names

    status = Inqncl3(& c_fd, c_cel_name, & c_elm_names_count, & c_bytes, & c_elm_names)
    el_names_count = c_elm_names_count

    for i in range(el_names_count):
        c_elm_names[17 * (i + 1) - 1] = ' '

    buffer_length = 17 * el_names_count
    c_elm_names[buffer_length] = '\0'
    
    c_cel_name[17] = '\0'
    cel_name = c_cel_name

    return status, cel_name, el_names_count, c_bytes, c_elm_names
#-------------------------------------------------------------------------


def inqnel(fd, elm_count_dimensions, np.ndarray[int, ndim=1, mode="c"] el_dimensions):
    """
    Inquire next element
    Keyword arguments:
        integer -- NEFIS file number
        integer -- number of dimensions
        integer -- element dimensions
    Return value:
        integer -- error number
        string  -- element name
        string  -- type of element
        integer -- size in bytes of thia element
        string  -- quantity of element
        string  -- unit of element
        string  -- description of element
        integer -- actual number of element dimensions
    Return value via argument list
        integer -- actual element dimensions
    """
    cdef int    c_fd
    cdef int    status
    cdef char * c_type
    cdef int    c_single_bytes
    cdef int    c_bytes
    cdef char * c_quantity
    cdef char * c_unit
    cdef char * c_description
    cdef int    c_count
    cdef int * c_dimensions

    elm_name = bytearray(20) * 17
    c_elm_name = elm_name

    buffer_length = 17
    buf1 = chr(20) * buffer_length
    c_type = buf1

    buf2 = chr(20) * buffer_length
    c_quantity = buf2

    buf3 = chr(20) * buffer_length
    c_unit = buf3

    buffer_length = 65
    buf4 = chr(20) * buffer_length
    c_description = buf4

    c_fd = fd
    elm_dimensions = np.arange(5).reshape(5)
    c_dimensions = &el_dimensions[0]

    c_count = elm_count_dimensions

    status = Inqnel( & c_fd, c_elm_name, c_type, c_quantity, c_unit, c_description, & c_single_bytes, & c_bytes, & c_count, c_dimensions)
    elm_size_bytes = c_bytes
    elm_count_dimensions = c_count

    c_elm_name[16] = '\0'
    elm_name = c_elm_name

    return status, elm_name, c_type, c_quantity, c_unit, c_description, c_single_bytes, elm_size_bytes, elm_count_dimensions
#-------------------------------------------------------------------------


def inqngr(fd, gr_dim_count, np.ndarray[int, ndim=1, mode="c"] gr_dimensions, np.ndarray[int, ndim=1, mode="c"] gr_order):
    """
    Inquire group definition of the next group (definition part)
    Keyword arguments:
        integer -- NEFIS file number
        integer -- number of group dimensions
        integer -- group dimensions
        integer -- group order
    Return value:
        integer -- error number
        string  -- group name
        string  -- cel name
        integer -- actual number of group dimensions
    """
    cdef int   c_fd
    cdef int   c_grp_dim_count
    cdef int * c_grp_dimensions
    cdef int * c_grp_order
    cdef int   status
    cdef char * c_grp_name
    cdef char * c_cel_name

    c_fd = fd
    c_grp_dim_count = gr_dim_count
    c_grp_dimensions = &gr_dimensions[0]
    c_grp_order = &gr_order[0]

    buffer_length = 17
    buf1 = chr(20) * buffer_length
    c_grp_name = buf1

    buf2 = chr(20) * buffer_length
    c_cel_name = buf2

    status = Inqngr( & c_fd, c_grp_name, c_cel_name, & c_grp_dim_count, c_grp_dimensions, c_grp_order)
    grp_name = c_grp_name
    cel_name = c_cel_name
    grp_dim_count = c_grp_dim_count

    return status, grp_name, c_cel_name, c_grp_dim_count
#-------------------------------------------------------------------------


def inqnia(fd, grp_name):
    """
    Inquire next integer attribute
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name
    Return value:
        integer -- error number
        string  -- attribute name
        string  -- attibute value
    """
    cdef int    c_fd
    cdef int    c_buffer
    cdef char * c_att_name
    cdef int    status

    c_fd = fd

    buffer_length = 17
    buf1 = chr(20) * buffer_length
    c_att_name = buf1

    status = Inqnia( & c_fd, grp_name, c_att_name, & c_buffer)

    return status, c_att_name, c_buffer
#-------------------------------------------------------------------------


def inqnra(fd, grp_name):
    """
    Inquire next float attribute
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name
    Return value:
        integer -- error number
        string  -- attribute name
        string  -- attibute value
    """
    cdef int    c_fd
    cdef float  c_buffer
    cdef char * c_att_name
    cdef int    status

    c_fd = fd

    buffer_length = 17
    buf1 = chr(20) * buffer_length
    c_att_name = buf1

    status = Inqnra( & c_fd, grp_name, c_att_name, & c_buffer)

    return status, c_att_name, c_buffer
#-------------------------------------------------------------------------


def inqnsa(fd, grp_name):
    """
    Inquire next string attribute
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name
    Return value:
        integer -- error number
        string  -- attribute name
        string  -- attibute value
    """
    cdef int    c_fd
    cdef char * c_att_value
    cdef char * c_att_name
    cdef int    status

    c_fd = fd

    buffer_length = 17
    buf1 = chr(20) * buffer_length
    c_att_name = buf1

    buf2 = chr(20) * buffer_length
    c_att_value = buf2

    status = Inqnsa(& c_fd, grp_name, c_att_name, c_att_value)

    return status, c_att_name, c_att_value[0:16]
#-------------------------------------------------------------------------


def inqnxt(fd):
    """
    Read corresponding group definition from the next data group
    Keyword arguments:
        integer -- NEFIS file number
    Return value:
        integer -- error number
        string  -- group name of data
        string  -- group name of definition
    """
    cdef int    c_fd
    cdef char * c_grp_name
    cdef char * c_grp_defined
    cdef int    status

    c_fd = fd

    buffer_length = 17
    buf1 = chr(20) * buffer_length
    c_grp_name = buf1

    buf2 = chr(20) * buffer_length
    c_grp_defined = buf2

    status = Inqnxt(& c_fd, c_grp_name, c_grp_defined)

    return status, c_grp_name[:16], c_grp_defined[:16]
#-------------------------------------------------------------------------


def neferr():
    """
    Retrieve NEFIS error message
    Keyword arguments:
        none
    Return value:
        integer -- error number
        string  -- error message
    """
    cdef char * message
    cdef int    status

    string = chr(0) * 1024
    message = string

    status = Neferr(0, message)

    return status, message
#-------------------------------------------------------------------------


def putels(fd, gr_name, el_name, np.ndarray[int, ndim=2, mode="c"] user_index, np.ndarray[int, ndim=1, mode="c"] user_order, buffer):
    """
    Put string values into element
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name
        string  -- element name
        integer -- user index array
        integer -- user order array
        string  -- list of character string
    Return value:
        integer -- error number
    """
    cdef int    c_fd
    cdef int    c_bl
    cdef int    status
    cdef char * c_buffer
    cdef int * c_user_index
    cdef int * c_user_order

    cdef char * c_type
    cdef int     c_single_bytes
    cdef char * c_quantity
    cdef char * c_unit
    cdef char * c_description
    cdef int     c_count
    cdef int * c_dimensions
    cdef np.ndarray[int, ndim = 1, mode = "c"] elm_dimensions

    c_fd = fd
    c_user_index = &user_index[0, 0]
    c_user_order = &user_order[0]

    buffer_length = 17
    buf1 = chr(20) * buffer_length
    c_type = buf1
    buf2 = chr(20) * buffer_length
    c_quantity = buf2
    buf3 = chr(20) * buffer_length
    c_unit = buf3
    buffer_length = 65
    buf4 = chr(20) * buffer_length
    c_description = buf4

    c_count = 5  # maximal number of dimensions for an element
    elm_dimensions = np.arange(5).reshape(5)
    for i in range(c_count):
        elm_dimensions[i] = 1
    c_dimensions = <int * > elm_dimensions.data

    status = Inqelm(& c_fd, el_name, c_type, & c_single_bytes, c_quantity, c_unit, c_description, & c_count, c_dimensions)

    length = c_single_bytes
    for i in range(c_count):
        elm_dimensions[i] = c_dimensions[i]

    multiply = 1
    for i in range(c_count):
        multiply = multiply * elm_dimensions[i]

    strings = bytearray(20) * length * multiply
    if any(isinstance(el, list) for el in buffer):
        buffer = list(itertools.chain(*buffer))
    for i in range(multiply):
        strings[length * i:length * (i + 1)] = buffer[i]
    c_buffer = strings

    status = Putels(& c_fd, gr_name, el_name, c_user_index, c_user_order, c_buffer)

    return status
#-------------------------------------------------------------------------


def putelt(fd, gr_name, el_name, np.ndarray[int, ndim=2, mode="c"] user_index, np.ndarray[int, ndim=1, mode="c"] user_order, buffer):
    """
    Put alpha-numeric values into element
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name
        string  -- element name
        integer -- user index array
        integer -- user order array
        string  -- list of character string
    Return value:
        integer -- error number
    """
    cdef int    c_fd
    cdef int    c_bl
    cdef int    status
    cdef char * c_buffer
    cdef int * c_user_index
    cdef int * c_user_order

    cdef char * c_type
    cdef int     c_single_bytes
    cdef char * c_quantity
    cdef char * c_unit
    cdef char * c_description
    cdef int     c_count
    cdef int * c_dimensions
    cdef np.ndarray[int, ndim = 1, mode = "c"] elm_dimensions

    c_fd = fd
    c_user_index = &user_index[0, 0]
    c_user_order = &user_order[0]

    buffer_length = 17
    buf1 = chr(20) * buffer_length
    c_type = buf1
    buf2 = chr(20) * buffer_length
    c_quantity = buf2
    buf3 = chr(20) * buffer_length
    c_unit = buf3
    buffer_length = 65
    buf4 = chr(20) * buffer_length
    c_description = buf4

    c_count = 5  # maximal number of dimensions for an element
    elm_dimensions = np.arange(5).reshape(5)
    for i in range(c_count):
        elm_dimensions[i] = 1
    c_dimensions = <int * > elm_dimensions.data

    status = Inqelm(& c_fd, el_name, c_type, & c_single_bytes, c_quantity, c_unit, c_description, & c_count, c_dimensions)

    length = c_single_bytes
    for i in range(c_count):
        elm_dimensions[i] = c_dimensions[i]

    multiply = 1
    for i in range(c_count):
        multiply = multiply * elm_dimensions[i]

    strings = bytearray(20) * length * multiply
    for i in range(length * multiply):
        strings[i:i * (i + 1)] = buffer[i]
    c_buffer = strings

    status = Putelt(& c_fd, gr_name, el_name, c_user_index, c_user_order, c_buffer)

    return status
#-------------------------------------------------------------------------


def putiat(fd, grp_name, att_name, att_value):
    """
    Put integer attribute value
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name
        integer -- attribute name
        string  -- integer attribute value
    Return value:
        integer -- error number
    """
    cdef int c_fd
    cdef int c_att_value
    cdef int status

    c_fd = fd
    c_att_value = att_value
    status = Putiat( & c_fd, grp_name, att_name, & c_att_value)

    return status
#-------------------------------------------------------------------------


def putrat(fd, grp_name, att_name, att_value):
    """
    Put float attribute value
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name
        integer -- attribute name
        string  -- integer attribute value
    Return value:
        integer -- error number
    """
    cdef int   c_fd
    cdef float c_att_value
    cdef int   status

    c_fd = fd
    c_att_value = att_value
    status = Putrat( & c_fd, grp_name, att_name, & c_att_value)

    return status
#-------------------------------------------------------------------------


def putsat(fd, grp_name, att_name, att_value):
    """
    Put string attribute value
    Keyword arguments:
        integer -- NEFIS file number
        string  -- group name
        integer -- attribute name
        string  -- integer attribute value
    Return value:
        integer -- error number
    """
    cdef int    c_fd
    cdef int    status

    c_fd = fd
    status = Putsat(& c_fd, grp_name, att_name, att_value)

    return status
