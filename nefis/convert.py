import netCDF4

import nefis.dataset as dataset

def nefis2nc_cf(src, dest, variables=None):
    """create a copy from the nefis file that tries to conform to CF conventions"""
    src_ds = dataset.Nefis(src)
    dst_ds = netCDF4.Dataset(dest, 'w')

    groups = src_ds.groups


    dst_ds.createDimension('time', groups['map-series']['group_size'])
    dst_ds.createDimension('n', src_ds.variables["NMAX"][:])
    dst_ds.createDimension('m', src_ds.variables["MMAX"][:])
    dst_ds.createDimension('k', src_ds.variables["KMAX"][:])

    variables = [
        {
            "name": "U1",
            "dimensions": ["time", "n", "m", "k"],
            "dtype": "float",
            "standard_name": "eastward_sea_velocity"
        }
    ]

    for name, var in variables:
        if name != 'U1':
            dst_ds.createVariable




    src_ds.close()
    dst_ds.close()


def nefis2nc_raw(src, dest, variables=None):
    """create a copy from the nefis file that matches the original file format as close as possible"""
    src_ds = dataset.Nefis(src)
    dst_ds = netCDF4.Dataset(dest, 'w')

    groups = src_ds.groups

    for name, group in groups.items():
        grp = dst_ds.createGroup(name)
        grp.createDimension("n_times", group["group_size"])

    src_ds.close()
    dst_ds.close()
