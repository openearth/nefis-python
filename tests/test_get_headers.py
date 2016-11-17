import logging
import os

import numpy as np
import pytest

import nefis.cnefis


logger = logging.getLogger(__name__)


TESTDIR = os.path.abspath(os.path.dirname(__file__))


def log_error(status):
    if status:
        status, msg = nefis.cnefis.neferr()
        logger.error("Nefis error: %s", msg)


@pytest.fixture()
def nefis_file():
    dat_file = os.path.join(TESTDIR, 'data/trim-f34.dat')
    def_file = os.path.join(TESTDIR, 'data/trim-f34.def')
    coding = ' '
    ac_type = 'r'
    fp = -1
    error, fp = nefis.cnefis.crenef(dat_file, def_file, coding, ac_type)
    log_error(error)
    logger.debug("yielding fp %s for %s", fp, dat_file)
    yield fp  # provide the fixture value
    error = nefis.cnefis.clsnef(fp)
    logger.debug("tearing down %s", dat_file)


def test_gethdf(nefis_file):
    error, def_header = nefis.cnefis.gethdf(nefis_file)
    log_error(error)
    assert error == 0, 'expected 0 status of gethdf'


def test_gethdt(nefis_file):
    error, def_header = nefis.cnefis.gethdt(nefis_file)
    log_error(error)
    assert error == 0, 'expected 0 status of gethdt'
