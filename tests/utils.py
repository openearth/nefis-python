import logging
import tempfile
import os

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
    _, base = tempfile.mkstemp()
    dat_file = base + '.dat'
    def_file = base + '.def'
    coding = ' '
    ac_type = 'c'
    fp = -1
    error, fp = nefis.cnefis.crenef(dat_file, def_file, coding, ac_type)
    log_error(error)
    logger.debug("yielding fp %s for %s", fp, dat_file)
    yield fp  # provide the fixture value
    error = nefis.cnefis.clsnef(fp)
    logger.debug("tearing down %s", dat_file)
    os.unlink(dat_file)
    os.unlink(def_file)


@pytest.fixture()
def f34_file():
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
