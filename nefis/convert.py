import netCDF4

import nefis.dataset as dataset


def nefis2nc(src, dest, variables=None):
    src_ds = dataset.Nefis(src)
    dst_ds = netCDF4.Dataset(dest, 'w')


    src_ds.close()
    dst_ds.close()
