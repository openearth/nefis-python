import nefis
import numpy as np

def test_nefis_putels_strings():
    #-------------------------------------------------------------------------------
    error, version = nefis.getnfv()
    print('')
    print('Library version: %s' % version[4:])
    print('')
    #-------------------------------------------------------------------------------
    dat_file = 'putels.dat'
    def_file = 'putels.def'
    coding = ' '
    ac_type = 'c'
    fp = -1
    print("------------")
    print(dat_file)
    print(def_file)
    print(coding)
    print(ac_type)
    print("------------")
    #-------------------------------------------------------------------------------
    error, fp = nefis.crenef(dat_file, def_file, coding, ac_type)
    if not error == 0:
        error, err_string = nefis.neferr()
        print('    NEFIS error string       : "%s"' % err_string)
        print('    =========')
    #-------------------------------------------------------------------------------
    print('---defelm---')
    elm_name = 'Element 1'
    elm_type = 'character'
    elm_single_byte = 20
    elm_quantity = 'names'
    elm_unit = '[-]'
    elm_description = 'Discharge station names'
    elm_count = 2
    #elm_data = np.arange(15).reshape(5,3)
    elm_dimensions = np.arange(elm_count).reshape(elm_count)
    elm_dimensions[0] = 2
    elm_dimensions[1] = 3

    error = nefis.defelm(fp, elm_name, elm_type, elm_single_byte, elm_quantity, elm_unit, elm_description, elm_count, elm_dimensions)
    if not error == 0:
        error, err_string = nefis.neferr()
        print('    NEFIS error string       : "%s"' % err_string)
        print('    =========')
    #-------------------------------------------------------------------------------
    print('---defcel---')
    cel_name = 'Cell 1'
    cel_names_count = 1
    elm_names = ['Element 1']

    error = nefis.defcel(fp, cel_name, cel_names_count, elm_names)
    if not error == 0:
        error, err_string = nefis.neferr()
        print('    NEFIS error string       : "%s"' % err_string)
        print('    =========')
    #-------------------------------------------------------------------------------
    print('---defgrp---')
    grp_defined = 'Grp 1'
    cel_name = 'Cell 1'
    grp_count = 1
    grp_dimensions = np.arange(5).reshape(5)
    grp_dimensions[0] = 11
    grp_dimensions[1] = 0
    grp_dimensions[2] = 0
    grp_dimensions[3] = 0
    grp_dimensions[4] = 0
    grp_order = np.arange(5).reshape(5)
    grp_order[0] = 1
    grp_order[1] = 2
    grp_order[2] = 3
    grp_order[3] = 4
    grp_order[4] = 5

    error = nefis.defgrp(fp, grp_defined, cel_name, grp_count, grp_dimensions, grp_order)
    if not error == 0:
        error, err_string = nefis.neferr()
        print('    NEFIS error string       : "%s"' % err_string)
        print('    =========')
    #-------------------------------------------------------------------------------
    print('---credat---')
    grp_name = 'Group 1'
    grp_defined = 'Grp 1'

    error = nefis.credat(fp, grp_name, grp_defined)
    if not error == 0:
        error, err_string = nefis.neferr()
        print('    NEFIS error string       : "%s"' % err_string)
        print('    =========')





    #-------------------------------------------------------------------------------
    print('---putels---')
    usr_index = np.arange(15).reshape(5,3)
    usr_index[0,0] = 11
    usr_index[0,1] = 11
    usr_index[0,2] = 1
    usr_index[1,0] = 0
    usr_index[1,1] = 0
    usr_index[1,2] = 0
    usr_index[2,0] = 0
    usr_index[2,1] = 0
    usr_index[2,2] = 0
    usr_index[3,0] = 0
    usr_index[3,1] = 0
    usr_index[3,2] = 0
    usr_index[4,0] = 0
    usr_index[4,1] = 0
    usr_index[4,2] = 0
    np.ascontiguousarray(usr_index, dtype=np.int32)
    usr_order = np.arange(5).reshape(5)
    usr_order[0] = 1
    usr_order[1] = 2
    usr_order[2] = 3
    usr_order[3] = 4
    usr_order[4] = 5
    np.ascontiguousarray(usr_order, dtype=np.int32)
    grp_name = 'Group 1'
    elm_name = 'Element 1'
    #names = ['Name 11', 'Name 21', 'Name 12', 'Name 22', 'Name 13', 'Name 23']
    names = ('Name 11', 'Name 21', 'Name 12', 'Name 22', 'Name 13', 'Name 23')
    #names = [['Name 11', 'Name 21', 'Name 12'], [ 'Name 22', 'Name 13', 'Name 23']]
    error = nefis.putels(fp, grp_name, elm_name, usr_index, usr_order, names)
    if not error == 0:
        error, err_string = nefis.neferr()
        print('    NEFIS error string       : "%s"' % err_string)
        print('    =========')
    #-------------------------------------------------------------------------------
    print('---clsnef---')
    error = nefis.clsnef(fp)
    print('------------')


if __name__ == "__main__":
    test_nefis_putels_strings()
