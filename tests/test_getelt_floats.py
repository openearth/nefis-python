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
    usr_index[0, :] = 1

    usr_order = np.arange(1, 6, dtype='int32')

    grp_name = 'map-const'
    elm_name = 'THICK'

    length = 20

    error, data = nefis.cnefis.getelt(
        f34_file,
        grp_name,
        elm_name,
        usr_index,
        usr_order,
        length
    )
    numbers = np.frombuffer(data, dtype='float32')
    assert np.allclose([0.4,  0.27,  0.18,  0.1,  0.05], numbers), "expected numbers in getelt"
