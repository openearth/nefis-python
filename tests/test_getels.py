import logging
import os

import numpy as np
import pytest

import nefis.cnefis
from .utils import (log_error, f34_file)

logger = logging.getLogger(__name__)



def test_getels_strings(f34_file):
    usr_index = np.zeros((5, 3), dtype='int32')
    usr_index[0, 0] = 1
    usr_index[0, 1] = 2
    usr_index[0, 2] = 3

    usr_order = np.arange(1, 6, dtype='int32')

    grp_name = 'map-const'
    elm_name = 'SIMDAT'
    length = 120
    error, names = nefis.cnefis.getels(f34_file, grp_name, elm_name, usr_index, usr_order, length)
    log_error(error)
    assert error == 0, 'Expected 0 error in getels'
    logger.info('names: %s', names)
