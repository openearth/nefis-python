import logging
import os
import struct

import numpy as np
import pytest

import nefis.cnefis
from .utils import (log_error, f34_file)


f34_file = f34_file

logger = logging.getLogger(__name__)


def test_nefis_getelt(f34_file):
    usr_index = np.zeros((5, 3), dtype='int32')
    usr_index[0,0] = 1
    usr_index[0,1] = 6
    usr_index[0,2] = 1

    usr_order = np.arange(1, 6, dtype='int32')

    grp_name = 'map-info-series'
    elm_name = 'ITMAPC'
    length = 24

    error, data = nefis.cnefis.getelt(f34_file, grp_name, elm_name, usr_index, usr_order, length)
    numbers = np.frombuffer(data, dtype='int32')
    assert np.allclose([150,  180,  210,  240,  270,  300], numbers), "expected numbers in getelt"
