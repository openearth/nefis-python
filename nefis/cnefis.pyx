import numpy as np
cimport numpy as np
import ctypes
import itertools

# corresponds to max_name (16) in nefis.h + 1 for 0 byte

DEF STRINGLENGTH = 16 + 1
DEF TEXTLENGTH = 64 + 1
# corresponds to LENGTH_ERROR_MESSAGE 1024
DEF ERRORMESSAGELENGTH = 1024
DEF MAXELEMENTS = 1024
DEF MAXDIMS = 5

# TODO: free all char* with libc.free

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
    cdef int c_fd = fd
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

    cdef bytes b_grp_name = grp_name.encode()
    cdef bytes b_grp_defined = grp_defined.encode()
    cdef char* c_grp_name = b_grp_name
    cdef char* c_grp_defined = b_grp_defined

    status = Credat(& c_fd, c_grp_name, c_grp_defined)

    return status
#-------------------------------------------------------------------------


def crenef(dat_file, def_file, coding, access):
    """
    Create or open NEFIS files
    Keyword arguments:
        string  -- data file name
        string  -- definition file name
        character  -- coding
        character  -- access type
    Return value:
        integer -- error number
    """
    cdef int c_fd

    c_fd = -1

    # we want to support unicode filenames, encode first
    cdef bytes b_dat_file = dat_file.encode()
    cdef bytes b_def_file = def_file.encode()

    cdef char* c_dat_file = b_dat_file
    cdef char* c_def_file = b_def_file


    status = Crenef(& c_fd, c_dat_file, c_def_file, ord(coding), ord(access))

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

    cdef bytes b_cl_name = cl_name.encode()
    cdef char* c_cl_name = b_cl_name

    c_fd = fd
    c_elm_names_count = el_names_count

    elm_names = bytearray(20) * STRINGLENGTH * el_names_count
    for i in range(el_names_count):
        elm_names[STRINGLENGTH * i:STRINGLENGTH * (i + 1)] = el_names[i].encode()
    c_elm_names = elm_names
    status = Defcel3(&c_fd, c_cl_name, c_elm_names_count, c_elm_names)
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
    cdef char* c_el_name
    cdef char* c_el_type
    cdef int   c_elm_single_byte
    cdef int   c_elm_dim_count
    cdef int * c_elm_dimensions
    cdef int   status

    b_el_name = el_name.encode()
    b_el_type = el_type.encode()
    b_el_quantity = el_quantity.encode()
    b_el_unit = el_unit.encode()
    b_el_desc = el_desc.encode()
    # convert to char*
    c_el_name = b_el_name
    c_el_type = b_el_type
    c_el_quantity = b_el_quantity
    c_el_unit = b_el_unit
    c_el_desc = b_el_desc

    c_fd = fd
    c_elm_single_byte = el_single_byte
    c_elm_dim_count = el_dim_count
    c_elm_dimensions = &el_dimensions[0]

    status = Defelm(& c_fd, c_el_name, c_el_type, c_elm_single_byte, c_el_quantity, c_el_unit, c_el_desc, c_elm_dim_count, c_elm_dimensions)

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
    cdef int   c_fd = fd
    cdef int   c_grp_dim_count = gr_dim_count
    cdef int * c_grp_dimensions
    cdef int * c_grp_order
    cdef int   status

    cdef bytes b_gr_name = gr_name.encode()
    cdef bytes b_cl_name = cl_name.encode()

    cdef char* c_gr_name = b_gr_name
    cdef char* c_cl_name = b_cl_name

    c_grp_dimensions = &gr_dimensions[0]
    c_grp_order = &gr_order[0]

    status = Defgrp(& c_fd, c_gr_name, c_cl_name, c_grp_dim_count, c_grp_dimensions, c_grp_order)

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
    cdef bytes b_gr_name = gr_name.encode()
    cdef bytes b_el_name = el_name.encode()

    cdef int    c_bl
    cdef int    status
    cdef char * c_buffer
    cdef int * c_user_index
    cdef int * c_user_order

    c_fd = fd
    c_bl = buffer_length
    c_user_index = &user_index[0, 0]
    c_user_order = &user_order[0]
    buf = b'\00' * buffer_length
    c_buffer = buf

    status = Getels( & c_fd, b_gr_name, b_el_name, c_user_index, c_user_order, & c_bl, c_buffer)
    if status == 0:
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
        bytes  -- raw bytes of element (introspect type and shape to unpack)
    """
    cdef int c_fd = fd
    cdef bytes b_gr_name = gr_name.encode()
    cdef bytes b_el_name = el_name.encode()
    cdef int c_bl
    cdef int status
    cdef bytes buf
    cdef char* c_buffer         # actually void* but not sure how to cast that
    cdef int* c_user_index
    cdef int* c_user_order

    c_fd = fd
    c_bl = buffer_length
    c_user_index = &user_index[0, 0]
    c_user_order = &user_order[0]
    buf = b'\00' * buffer_length
    c_buffer = buf

    status = Getelt( & c_fd, b_gr_name, b_el_name, c_user_index, c_user_order, & c_bl, c_buffer)
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
    buf = b'\20' * 128
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
    buf = b'\20' * buffer_length
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
    cdef int c_fd = fd
    cdef bytes b_grp_name = grp_name.encode()
    cdef char* c_grp_name = b_grp_name
    cdef bytes b_att_name = att_name.encode()
    cdef char* c_att_name = b_att_name
    cdef int c_value = 0
    cdef int status

    status = Getiat(&c_fd, c_grp_name, c_att_name, &c_value)
    print(c_grp_name, c_att_name)

    return status, c_value
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
    cdef char * c_version
    cdef bytes  b_version
    cdef int    status

    b_version = b'\00' * TEXTLENGTH
    c_version = b_version

    status = Getnfv(&c_version)

    b_version = c_version

    return status, b_version.decode().rstrip()
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
    cdef int   c_fd = fd
    cdef bytes b_grp_name = grp_name.encode()
    cdef bytes b_att_name = att_name.encode()
    cdef float c_buffer
    cdef int   status

    status = Getrat( & c_fd, b_grp_name, b_att_name, & c_buffer)

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
    cdef bytes b_grp_name = grp_name.encode()
    cdef bytes b_att_name = att_name.encode()
    cdef char* c_buffer
    cdef bytes b_buffer
    cdef int    status

    c_fd = fd
    # allocate bytes
    b_buffer = b'\00' * STRINGLENGTH
    c_buffer = b_buffer
    status = Getsat(& c_fd, b_grp_name, b_att_name, c_buffer)
    b_buffer = c_buffer

    return status, b_buffer.decode().rstrip()
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
    cdef int c_fd = fd
    cdef bytes b_cl_name = cl_name.encode()
    cdef int c_elm_names_count = el_names_count
    cdef int     status
    cdef char ** names
    cdef char * c_elm_names

    buffer_length = STRINGLENGTH * el_names_count
    elm_names = b'\20' * buffer_length
    c_elm_names = elm_names

    status = Inqcel3( &c_fd, b_cl_name, &c_elm_names_count, c_elm_names)
    el_names_count = c_elm_names_count
    if status == 0:
        for i in range(el_names_count):
            c_elm_names[STRINGLENGTH * (i + 1) - 1] = ' '

    buffer_length = STRINGLENGTH * el_names_count
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
    cdef int c_fd = fd
    cdef bytes b_grp_name = grp_name.encode()
    cdef int status
    cdef char* c_buffer

    buffer_length = STRINGLENGTH
    buf = b'\20' * buffer_length
    c_buffer = buf

    status = Inqdat(&c_fd, b_grp_name, c_buffer)

    c_buffer[buffer_length] = '\0'

    return status, c_buffer
#-------------------------------------------------------------------------


def inqelm(fd, elm_name):
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
    cdef int c_fd = fd
    cdef bytes b_elm_name = elm_name.encode()
    cdef int    status
    cdef char * c_type
    cdef bytes  b_type
    cdef int    c_single_bytes
    cdef char * c_quantity
    cdef bytes  b_quantity
    cdef char * c_unit
    cdef bytes  b_unit
    cdef char * c_description
    cdef bytes  b_description
    cdef int    c_count = MAXDIMS
    cdef np.ndarray[int, ndim=1, mode="c"] el_dimensions = np.zeros(MAXDIMS, dtype="int32")
    cdef int *  c_dimensions



    b_type = b'\00' * STRINGLENGTH
    c_type = b_type

    b_quantity = b'\00' * STRINGLENGTH
    c_quantity = b_quantity

    b_unit = b'\00' * STRINGLENGTH
    c_unit = b_unit

    b_description = b'\00' * TEXTLENGTH
    c_description = b_description

    c_dimensions = &el_dimensions[0]

    status = Inqelm(&c_fd, b_elm_name, c_type, & c_single_bytes, c_quantity, c_unit, c_description, & c_count, c_dimensions)

    b_type = c_type
    b_quantity = c_quantity
    b_unit = c_unit
    b_description = c_description

    return (
        status,
        b_type.decode().rstrip(),
        c_single_bytes,
        b_quantity.decode().rstrip(),
        b_unit.decode().rstrip(),
        b_description.decode().rstrip(),
        c_count,
        el_dimensions[:c_count]
    )
#-------------------------------------------------------------------------


def inqfcl(fd):
    """
    Inquire cel definition of the first cel
    Keyword arguments:
        integer -- NEFIS file number
    Return value:
        string  -- cel name
        integer -- error number
        integer -- actual number of elements in cel
        integer -- size of cel in bytes
        string  -- list of element names
    """
    cdef int c_fd = fd

    cdef char* c_cel_name
    cdef bytes b_cel_name
    cdef int c_bytes
    cdef int status
    cdef int c_elm_names_count
    cdef char ** names

    b_cel_name = b'\00' * STRINGLENGTH
    c_cel_name = b_cel_name
    buffer_length = STRINGLENGTH * MAXELEMENTS
    # fill with spaces
    elm_names = b'\20' * buffer_length
    cdef char* c_elm_names = elm_names

    status = Inqfcl3(&c_fd, c_cel_name, &c_elm_names_count, &c_bytes, &c_elm_names)

    b_cel_name = c_cel_name
    b_cel_name = b_cel_name.rstrip(b'= ')
    elm_names = []
    if status == 0:
        for i in range(c_elm_names_count):
            name = c_elm_names[STRINGLENGTH*i:STRINGLENGTH*(i + 1)-1].decode().rstrip('= ')
            elm_names.append(name)


    return status, b_cel_name.decode().rstrip(), c_elm_names_count, c_bytes, elm_names
#-------------------------------------------------------------------------


def inqfel(fd):
    """
    Inquire element definition of the first element
    Keyword arguments:
        integer -- NEFIS file number
    Return value:
        integer -- error number
        string  -- element name
        string  -- type of element
        integer -- size in bytes of thia element
        string  -- quantity of element
        string  -- unit of element
        string  -- description of element
        integer -- actual number of element dimensions
        integer -- actual element dimensions
    """
    cdef int    c_fd = fd
    cdef int    status
    cdef char * c_elm_name
    cdef bytes  b_elm_name

    cdef char * c_type
    cdef bytes  b_type

    cdef int    c_single_bytes
    cdef int    c_bytes

    cdef char * c_quantity
    cdef bytes  b_quantity

    cdef char * c_unit
    cdef bytes  b_unit

    cdef char * c_description
    cdef bytes  b_description

    cdef np.ndarray[int, ndim=1, mode="c"] el_dimensions
    cdef int    c_count = MAXDIMS
    cdef int *  c_dimensions

    b_elm_name = b'\00' * STRINGLENGTH
    c_elm_name = b_elm_name

    b_type = b'\00' * STRINGLENGTH
    c_type = b_type

    b_quantity = b'\00' * STRINGLENGTH
    c_quantity = b_quantity

    b_unit = b'\00' * STRINGLENGTH
    c_unit = b_unit

    b_description = b'\00' * TEXTLENGTH
    c_description = b_description

    el_dimensions = np.zeros(MAXDIMS, dtype="int32")
    c_dimensions = &el_dimensions[0]

    status = Inqfel( & c_fd, c_elm_name, c_type, c_quantity, c_unit, c_description, & c_single_bytes, & c_bytes, & c_count, c_dimensions)

    b_quantity = c_quantity
    b_elm_name = c_elm_name
    b_type = c_type
    b_unit = c_unit
    b_description = c_description


    return (
        status,
        b_elm_name.decode().rstrip(),
        b_type.decode().rstrip(),
        b_quantity.decode().rstrip(),
        b_unit.decode().rstrip(),
        b_description.decode().rstrip(),
        c_single_bytes,
        c_bytes,
        c_count,
        el_dimensions[:c_count]
    )
#-------------------------------------------------------------------------


def inqfgr(fd):
    """
    Inquire group definition of the first group (definition part)
    Keyword arguments:
        integer -- NEFIS file number
    Return value:
        integer -- error number
        string  -- group name
        string  -- cel name
        integer -- actual number of group dimensions
        integer -- group dimensions
        integer -- group order
    """
    cdef int   c_fd = fd

    cdef char* c_grp_name
    cdef bytes b_grp_name
    cdef char* c_cel_name
    cdef bytes b_cel_name
    cdef np.ndarray[int, ndim=1, mode="c"] gr_dimensions = np.zeros(MAXDIMS, dtype="int32")
    cdef np.ndarray[int, ndim=1, mode="c"] gr_order = np.zeros(MAXDIMS, dtype="int32")
    cdef int   c_grp_dim_count
    cdef int * c_grp_dimensions = &gr_dimensions[0]
    cdef int * c_grp_order = &gr_order[0]
    cdef int   status

    # allocate memory
    b_grp_name = b'\00' * STRINGLENGTH
    c_grp_name = b_grp_name
    b_cel_name = b'\00' * STRINGLENGTH
    c_cel_name = b_cel_name

    status = Inqfgr( &c_fd, c_grp_name, c_cel_name, & c_grp_dim_count, c_grp_dimensions, c_grp_order)

    b_grp_name = c_grp_name
    b_cel_name = c_cel_name

    return (
        status,
        b_grp_name.decode().rstrip(),
        b_cel_name.decode().rstrip(),
        c_grp_dim_count,
        gr_dimensions[:c_grp_dim_count],
        gr_order[:c_grp_dim_count]
    )
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
    cdef int    c_fd = fd
    cdef bytes b_grp_name = grp_name.encode()
    cdef int    c_buffer
    cdef char * c_att_name
    cdef int    status

    buffer_length = STRINGLENGTH
    buf1 = b'\20' * buffer_length
    c_att_name = buf1

    status = Inqfia( &c_fd, b_grp_name, c_att_name, & c_buffer)

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
    cdef int    c_fd = fd
    cdef bytes b_grp_name = grp_name.encode()
    cdef float  c_buffer
    cdef char * c_att_name
    cdef int    status

    buffer_length = STRINGLENGTH
    buf1 = b'\20' * buffer_length
    c_att_name = buf1

    status = Inqfra( &c_fd, b_grp_name, c_att_name, & c_buffer)

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
    cdef int    c_fd = fd
    cdef bytes b_grp_name = grp_name.encode()
    cdef char * c_att_value
    cdef bytes  b_att_value
    cdef char * c_att_name
    cdef bytes  b_att_name
    cdef int    status

    buffer_length = STRINGLENGTH
    buf1 = b'\20' * buffer_length
    c_att_name = buf1

    buf2 = b'\20' * buffer_length
    c_att_value = buf2

    status = Inqfsa(&c_fd, b_grp_name, c_att_name, c_att_value)
    b_att_name = c_att_name
    b_att_value = c_att_value

    return status, b_att_name.decode().rstrip(), b_att_value.decode().rstrip()
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
    cdef int      c_fd
    cdef char[STRINGLENGTH] c_grp_name
    cdef bytes    b_grp_name
    cdef char[STRINGLENGTH] c_grp_defined
    cdef bytes    b_grp_defined
    cdef int      status

    c_fd = fd

    status = Inqfst(& c_fd, c_grp_name, c_grp_defined)
    b_grp_name = c_grp_name
    b_grp_defined = c_grp_defined

    return status, b_grp_name.decode().rstrip(), b_grp_defined.decode().rstrip()
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
    cdef bytes b_grp_defined = grp_defined.encode()
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

    buffer_length = STRINGLENGTH
    buf1 = b'\20' * buffer_length
    c_cel_name = buf1

    status = Inqfgr( & c_fd, b_grp_defined, c_cel_name, & c_grp_dim_count, c_grp_dimensions, c_grp_order)
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
    cdef int c_fd = fd
    cdef bytes b_grp_name = grp_name.encode()
    cdef int status
    cdef int c_buffer

    status = Inqmxi( &c_fd, b_grp_name, & c_buffer)

    return status, c_buffer
#-------------------------------------------------------------------------


def inqncl(fd):
    """
    Inquire next cel
    Keyword arguments:
        integer -- NEFIS file number
    Return value:
        integer -- error number
        string  -- cel name
        integer -- actual number of elements in cel
        integer -- size of cel in bytes
        string  -- list of element names
    """
    cdef int c_fd = fd
    cdef int c_elm_names_count
    cdef int c_bytes
    cdef int status
    cdef char* c_elm_names
    cdef char* c_cel_name
    cdef bytes  b_cel_name

    buffer_length = STRINGLENGTH * MAXELEMENTS
    elm_names = b'\00' * buffer_length

    b_cel_name = b'\00' * STRINGLENGTH
    c_cel_name = b_cel_name
    c_elm_names = elm_names

    status = Inqncl3(&c_fd, c_cel_name, &c_elm_names_count, &c_bytes, &c_elm_names)
    b_cel_name = c_cel_name
    el_names_count = c_elm_names_count
    names = []
    if status == 0:
        for i in range(el_names_count):
            name = c_elm_names[i*STRINGLENGTH:(i+1)*STRINGLENGTH-1]
            names.append(name.decode().rstrip('= '))
    return status, b_cel_name.decode().rstrip(), el_names_count, c_bytes, names
#-------------------------------------------------------------------------


def inqnel(fd):
    """
    Inquire next element
    Keyword arguments:
        integer -- NEFIS file number
    Return value:
        integer -- error number
        string  -- element name
        string  -- type of element
        integer -- size in bytes of thia element
        string  -- quantity of element
        string  -- unit of element
        string  -- description of element
        integer -- number of dimensions
        integer -- element dimensions
    """
    cdef int    c_fd = fd
    cdef int    status
    cdef char*  c_elm_name
    cdef bytes  b_elm_name
    cdef char * c_type
    cdef bytes  b_type
    cdef int    c_single_bytes
    cdef int    c_bytes
    cdef char * c_quantity
    cdef bytes  b_quantity
    cdef char * c_unit
    cdef bytes  b_unit
    cdef char * c_description
    cdef bytes  b_description
    cdef int    c_count = MAXDIMS
    cdef np.ndarray[int, ndim=1, mode="c"] el_dimensions = np.zeros(MAXDIMS, dtype="int32")
    cdef int*   c_el_dimensions

    b_elm_name = b'\00' * STRINGLENGTH
    c_elm_name = b_elm_name

    b_type = b'\00' * STRINGLENGTH
    c_type = b_type

    b_quantity = b'\00' * STRINGLENGTH
    c_quantity = b_quantity

    b_unit = b'\00' * STRINGLENGTH
    c_unit = b_unit

    b_description = b'\00' * TEXTLENGTH
    c_description = b_description

    c_el_dimensions = &el_dimensions[0]


    status = Inqnel( & c_fd, c_elm_name, c_type, c_quantity, c_unit, c_description, & c_single_bytes, & c_bytes, &c_count, c_el_dimensions)


    b_elm_name = c_elm_name
    b_type = c_type
    b_quantity = c_quantity
    b_unit = c_unit
    b_description = c_description

    elm_name = c_elm_name

    return (
        status,
        b_elm_name.decode().rstrip(),
        b_type.decode().rstrip(),
        b_quantity.decode().rstrip(),
        b_unit.decode().rstrip(),
        b_description.decode().rstrip(),
        c_single_bytes,
        c_bytes,
        c_count,
        el_dimensions[:c_count]
    )
#-------------------------------------------------------------------------


def inqngr(fd):
    """
    Inquire group definition of the next group (definition part)
    Keyword arguments:
        integer -- NEFIS file number
    Return value:
        integer -- error number
        string  -- group name
        string  -- cel name
        integer -- number of group dimensions
        integer -- group dimensions
        integer -- group order
    """
    cdef int   c_fd = fd
    cdef int   status
    cdef int   c_grp_dim_count
    cdef np.ndarray[int, ndim=1, mode="c"] grp_dimensions = np.zeros(MAXDIMS, dtype="int32")
    cdef int * c_grp_dimensions
    cdef np.ndarray[int, ndim=1, mode="c"] grp_order = np.zeros(MAXDIMS, dtype="int32")
    cdef int * c_grp_order
    cdef char * c_grp_name
    cdef bytes  b_grp_name
    cdef char * c_cel_name
    cdef bytes  b_cel_name

    c_grp_dimensions = &grp_dimensions[0]
    c_grp_order = &grp_order[0]

    b_grp_name = b'\00' * STRINGLENGTH
    c_grp_name = b_grp_name

    b_cel_name = b'\00' * STRINGLENGTH
    c_cel_name = b_cel_name

    status = Inqngr( & c_fd, c_grp_name, c_cel_name, & c_grp_dim_count, c_grp_dimensions, c_grp_order)

    b_grp_name = c_grp_name
    b_cel_name = c_cel_name
    c_grp_dim_count

    return (
        status,
        b_grp_name.decode().rstrip(),
        b_cel_name.decode().rstrip(),
        c_grp_dim_count,
        grp_dimensions[:c_grp_dim_count],
        grp_order[:c_grp_dim_count]
    )
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
    cdef int c_fd = fd
    cdef bytes b_grp_name = grp_name.encode()
    cdef int    c_buffer
    cdef char * c_att_name
    cdef int    status

    buffer_length = STRINGLENGTH
    buf1 = b'\20' * buffer_length
    c_att_name = buf1

    status = Inqnia( &c_fd, b_grp_name, c_att_name, & c_buffer)

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
    cdef int    c_fd = fd
    cdef bytes b_grp_name = grp_name.encode()
    cdef float  c_buffer
    cdef char * c_att_name
    cdef int    status

    buffer_length = STRINGLENGTH
    buf1 = b'\20' * buffer_length
    c_att_name = buf1

    status = Inqnra( &c_fd, b_grp_name, c_att_name, & c_buffer)

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
    cdef int    c_fd = fd
    cdef bytes b_grp_name = grp_name.encode()
    cdef char * c_att_value
    cdef char * c_att_name
    cdef int    status



    buffer_length = STRINGLENGTH
    buf1 = b'\20' * buffer_length
    c_att_name = buf1

    buf2 = b'\20' * buffer_length
    c_att_value = buf2

    status = Inqnsa(& c_fd, b_grp_name, c_att_name, c_att_value)

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
    cdef char[STRINGLENGTH] c_grp_name
    cdef bytes  b_grp_name
    cdef char[STRINGLENGTH] c_grp_defined
    cdef bytes  b_grp_defined
    cdef int    status

    c_fd = fd

    status = Inqnxt(& c_fd, c_grp_name, c_grp_defined)

    b_grp_name = c_grp_name
    b_grp_defined = c_grp_defined

    return status, b_grp_name.decode(errors='replace').rstrip(), b_grp_defined.decode(errors='replace').rstrip()
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
    cdef char[ERRORMESSAGELENGTH] message
    cdef int    status

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
    cdef int     c_count = MAXDIMS
    cdef int * c_dimensions
    cdef np.ndarray[int, ndim = 1, mode = "c"] elm_dimensions

    c_fd = fd
    c_user_index = &user_index[0, 0]
    c_user_order = &user_order[0]

    buffer_length = STRINGLENGTH
    buf1 = b'\20' * buffer_length
    c_type = buf1
    buf2 = b'\20' * buffer_length
    c_quantity = buf2
    buf3 = b'\20' * buffer_length
    c_unit = buf3
    buffer_length = 65
    buf4 = b'\20' * buffer_length
    c_description = buf4

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
    cdef int     c_count = MAXDIMS
    cdef int * c_dimensions
    cdef np.ndarray[int, ndim = 1, mode = "c"] elm_dimensions

    c_fd = fd
    c_user_index = &user_index[0, 0]
    c_user_order = &user_order[0]

    buffer_length = STRINGLENGTH
    buf1 = b'\20' * buffer_length
    c_type = buf1
    buf2 = b'\20' * buffer_length
    c_quantity = buf2
    buf3 = b'\20' * buffer_length
    c_unit = buf3
    buffer_length = 65
    buf4 = b'\20' * buffer_length
    c_description = buf4

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
    cdef int c_fd = fd
    cdef bytes b_grp_name = grp_name.encode()
    cdef bytes b_att_name = att_name.encode()

    cdef int c_att_value = att_value
    cdef int status

    c_fd = fd
    status = Putiat( &c_fd, b_grp_name, b_att_name, &c_att_value)

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
    cdef int   c_fd = fd
    cdef bytes b_grp_name = grp_name.encode()
    cdef bytes b_att_name = att_name.encode()
    cdef float c_att_value = att_value
    cdef int   status

    status = Putrat(&c_fd, b_grp_name, b_att_name, &c_att_value)

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
    cdef int    c_fd = fd
    cdef bytes b_grp_name = grp_name.encode()
    cdef char* c_grp_name = b_grp_name
    cdef bytes b_att_name = att_name.encode()
    cdef char* c_att_name = b_att_name
    cdef bytes b_att_value = att_value.encode()
    cdef char* c_att_value = b_att_value
    cdef int    status

    status = Putsat(& c_fd, c_grp_name, c_att_name, c_att_value)

    return status
