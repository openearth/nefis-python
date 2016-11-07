import logging
import os
import struct
import faulthandler

import numpy as np
import pytest

import nefis.cnefis
from .utils import (log_error, f34_file)

faulthandler.enable()

f34_file = f34_file

logger = logging.getLogger(__name__)


def test_inqcel(f34_file):
    cel_name = 'Cell 1'
    count = 2
    error, count, elm_names = nefis.cnefis.inqcel(f34_file, cel_name, count)
    log_error(error)


def test_inqdat(f34_file):
    grp_name = 'Group 1'
    error, grp_defined = nefis.cnefis.inqdat(f34_file, grp_name)


def test_inqelm(f34_file):
    elm_name = 'Element 1'
    elm_dimensions = np.zeros(5, dtype='int32')

    (
        error,
        elm_type,
        elm_single_byte,
        elm_quantity,
        elm_unit,
        elm_description,
        elm_count
    ) = nefis.cnefis.inqelm(f34_file, elm_name, elm_dimensions)


def test_inqfcl(f34_file):
    count = 1
    error, cel_name, count, bytes, elm_names = nefis.cnefis.inqfcl(f34_file)


def test_inqncl(f34_file):
    count = 2
    error, cel_name, count, bytes, elm_names = nefis.cnefis.inqncl(f34_file)


def test_inqfel(f34_file):
    elm_dimensions = np.zeros(5, dtype='int32')
    count = 1
    (
        error,
        elm_name,
        elm_type,
        elm_quantity,
        elm_unit,
        elm_description,
        elm_single_byte,
        elm_size,
        elm_count
    ) = nefis.cnefis.inqfel(f34_file, count, elm_dimensions)


def test_inqnel(f34_file):
    elm_dimensions = np.zeros(5, dtype='int32')
    elm_count_dimensions = 1
    (
        error,
        elm_name,
        elm_type,
        elm_quantity,
        elm_unit,
        elm_description,
        elm_single_byte,
        elm_size,
        elm_count
    ) = nefis.cnefis.inqnel(f34_file, elm_count_dimensions, elm_dimensions)


def test_inqfgr(f34_file):
    grp_count_dimensions = 4
    grp_dimensions = np.zeros(5, dtype='int32')
    grp_order = np.zeros(5, dtype='int32')

    (
        error,
        grp_defined,
        cel_name,
        grp_dim_count
    ) = nefis.cnefis.inqfgr(f34_file, grp_count_dimensions, grp_dimensions, grp_order)


def test_inqngr(f34_file):
    grp_count_dimensions = 0
    grp_dimensions = np.zeros(5, dtype='int32')
    grp_order = np.zeros(5, dtype='int32')

    (
        error,
        grp_defined,
        cel_name,
        grp_dim_count
    ) = nefis.cnefis.inqngr(f34_file, grp_count_dimensions, grp_dimensions, grp_order)


def test_inqfia(f34_file):
    grp_name = 'Group 1'
    error, att_name, att_value = nefis.cnefis.inqfia(f34_file, grp_name)


def test_inqnia(f34_file):
    grp_name = 'Group 1'
    error, att_name, att_value = nefis.cnefis.inqnia(f34_file, grp_name)


def test_inqfra(f34_file):
    grp_name = 'Group 1'
    error, att_name, att_value = nefis.cnefis.inqfra(f34_file, grp_name)


def test_inqnra(f34_file):
    grp_name = 'Group 1'
    error, att_name, att_value = nefis.cnefis.inqnra(f34_file, grp_name)


def test_inqfsa(f34_file):
    grp_name = 'Group 1'
    error, att_name, att_value = nefis.cnefis.inqfsa(f34_file, grp_name)


def test_inqnsa(f34_file):
    grp_name = 'Group 1'
    error, att_name, att_value = nefis.cnefis.inqnsa(f34_file, grp_name)


def test_inqfst(f34_file):
    error, grp_name, grp_defined = nefis.cnefis.inqfst(f34_file)


def test_inqnxt(f34_file):
    error, grp_name, grp_defined = nefis.cnefis.inqnxt(f34_file)


def test_inqgrp(f34_file):
    grp_defined = 'Grp 1'
    grp_count = 1
    grp_dimensions = np.zeros(5, dtype='int32')
    grp_order = np.arange(1, 6, dtype='int32')
    error, cel_name, grp_count = nefis.cnefis.inqgrp(f34_file, grp_defined, grp_count, grp_dimensions, grp_order)


def test_inqmxi(f34_file):
    grp_name = 'Group 1'
    error, max_index = nefis.cnefis.inqmxi(f34_file, grp_name)
