import nefis.cnefis
import numpy as np
import struct

# import array


def test_nefis_putelt_integers():
    # -------------------------------------------------------------------------------
    error, version = nefis.cnefis.getnfv()
    print("")
    print("Library version: %s" % version[4:])
    print("")
    # -------------------------------------------------------------------------------
    dat_file = "put_integers.dat"
    def_file = "put_integers.def"
    coding = " "
    ac_type = "c"
    fp = -1
    print("------------")
    print(dat_file)
    print(def_file)
    print(coding)
    print(ac_type)
    print("------------")
    # -------------------------------------------------------------------------------
    error, fp = nefis.cnefis.crenef(dat_file, def_file, coding, ac_type)
    if not error == 0:
        error, err_string = nefis.cnefis.neferr()
        print('    NEFIS error string       : "%s"' % err_string)
        print("    =========")
    # -------------------------------------------------------------------------------
    elm_name = "Elm 3"
    elm_type = "INTEGER"
    elm_single_byte = 4
    elm_quantity = "integers"
    elm_unit = "[-]"
    elm_description = "Just integers"
    elm_count = 2
    # elm_data = np.arange(15).reshape(5,3)
    elm_dimensions = np.arange(elm_count).reshape(elm_count)
    elm_dimensions[0] = 20
    elm_dimensions[1] = 5
    elm_dimensions = np.ascontiguousarray(elm_dimensions, dtype=np.int32)
    error = nefis.cnefis.defelm(
        fp,
        elm_name,
        elm_type,
        elm_single_byte,
        elm_quantity,
        elm_unit,
        elm_description,
        elm_count,
        elm_dimensions,
    )
    print("NEFIS error code (defelm): %d" % error)
    if not error == 0:
        error, err_string = nefis.cnefis.neferr()
        print("    NEFIS error string       : %s" % err_string)
        print("=========")
    # -------------------------------------------------------------------------------
    print("---defcel---")
    cel_name = "Cell 1"
    cel_names_count = 1
    elm_names = ["Elm 3"]

    error = nefis.cnefis.defcel(fp, cel_name, cel_names_count, elm_names)
    if not error == 0:
        error, err_string = nefis.cnefis.neferr()
        print('    NEFIS error string       : "%s"' % err_string)
        print("    =========")
    # -------------------------------------------------------------------------------
    print("---defgrp---")
    grp_defined = "Grp 1"
    cel_name = "Cell 1"
    grp_count = 1
    grp_dimensions = np.arange(5).reshape(5)
    grp_dimensions[0] = 11
    grp_dimensions[1] = 0
    grp_dimensions[2] = 0
    grp_dimensions[3] = 0
    grp_dimensions[4] = 0
    grp_dimensions = np.ascontiguousarray(grp_dimensions, dtype=np.int32)
    grp_order = np.arange(5).reshape(5)
    grp_order[0] = 1
    grp_order[1] = 2
    grp_order[2] = 3
    grp_order[3] = 4
    grp_order[4] = 5
    grp_order = np.ascontiguousarray(grp_order, dtype=np.int32)

    error = nefis.cnefis.defgrp(
        fp, grp_defined, cel_name, grp_count, grp_dimensions, grp_order
    )
    if not error == 0:
        error, err_string = nefis.cnefis.neferr()
        print('    NEFIS error string       : "%s"' % err_string)
        print("    =========")
    # -------------------------------------------------------------------------------
    print("---credat---")
    grp_name = "Group 1"
    grp_defined = "Grp 1"

    error = nefis.cnefis.credat(fp, grp_name, grp_defined)
    if not error == 0:
        error, err_string = nefis.cnefis.neferr()
        print('    NEFIS error string       : "%s"' % err_string)
        print("    =========")

    # -------------------------------------------------------------------------------
    print("---putelt---")
    usr_index = np.arange(15).reshape(5, 3)
    usr_index[0, 0] = 11
    usr_index[0, 1] = 11
    usr_index[0, 2] = 1
    usr_index[1, 0] = 0
    usr_index[1, 1] = 0
    usr_index[1, 2] = 0
    usr_index[2, 0] = 0
    usr_index[2, 1] = 0
    usr_index[2, 2] = 0
    usr_index[3, 0] = 0
    usr_index[3, 1] = 0
    usr_index[3, 2] = 0
    usr_index[4, 0] = 0
    usr_index[4, 1] = 0
    usr_index[4, 2] = 0
    usr_index = np.ascontiguousarray(usr_index, dtype=np.int32)

    usr_order = np.arange(5).reshape(5)
    usr_order[0] = 1
    usr_order[1] = 2
    usr_order[2] = 3
    usr_order[3] = 4
    usr_order[4] = 5
    usr_order = np.ascontiguousarray(usr_order, dtype=np.int32)

    grp_name = "Group 1"
    elm_name = "Elm 3"

    floot = np.zeros(100, dtype=int, order="C")
    floats = np.zeros((20, 5), dtype=int, order="C")
    for i in range(20):
        for j in range(5):
            k = j * 20 + i
            floats[i, j] = (i + 1) * (j + 1)
            floot[k] = floats[i, j]
    print(floats)
    print("")

    fmt = "%di" % (len(floot))
    numbers = struct.pack(fmt, *floot)

    error = nefis.cnefis.putelt(fp, grp_name, elm_name, usr_index, usr_order, numbers)

    if not error == 0:
        error, err_string = nefis.cnefis.neferr()
        print('    NEFIS error string       : "%s"' % err_string)
        print("    =========")
    # -------------------------------------------------------------------------------
    print("---clsnef---")
    error = nefis.cnefis.clsnef(fp)
    print("------------")
    assert error == 0, "expected error 0"


if __name__ == "__main__":
    test_nefis_putelt_integers()
