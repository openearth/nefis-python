# Always prefer setuptools over distutils
from setuptools import setup, find_packages
from codecs import open  # To use a consistent encoding
from os import path
from distutils.extension import Extension

import numpy as np
from Cython.Build import cythonize


with open('README.rst') as readme_file:
    readme = readme_file.read()

with open('HISTORY.rst') as history_file:
    history = history_file.read()

with open('requirements.txt') as requirements_file:
    requirements = requirements_file.readlines()

with open('requirements_dev.txt') as requirements_dev_file:
    test_requirements = requirements_dev_file.readlines()

cmdclass = {}
ext_modules = cythonize([
    Extension(
        # I want this to be nefis.cnefis... not sure why it doesn't work
        "nefis.cnefis",
        ["nefis/cnefis.pyx"],
        # TODO: since Delft3D released in 2013 this is named NefisSO
        # rename it back and bundle it by default (using wheel files, for OSX, Linux and Windows)
        libraries=["nefis"]
    )
])


here = path.abspath(path.dirname(__file__))

# Get the long description from the relevant file
with open(path.join(here, 'DESCRIPTION.rst'), encoding='utf-8') as f:
    long_description = f.read()

setup(
    name='nefis',

    # Versions should comply with PEP440.  For a discussion on single-sourcing
    # the version across setup.py and the project code, see
    # http://packaging.python.org/en/latest/tutorial.html#version
    version='0.4.0',

    description='NEFIS library',
    long_description=long_description,

    # The project's main homepage.
    url='https://github.com/openearth/nefis-python',

    # Author details
    author='Jan Mooiman',
    author_email='jan.mooiman@deltares.nl',

    # Choose your license
    license='LGPLv3',

    # See https://pypi.python.org/pypi?%3Aaction=list_classifiers
    classifiers=[
        # How mature is this project? Common values are
        #   3 - Alpha
        #   4 - Beta
        #   5 - Production/Stable
        'Development Status :: 3 - Alpha',

        # Indicate who your project is intended for
        'Intended Audience :: Developers',
        'Intended Audience :: Science/Research',
        'Topic :: Scientific/Engineering',

        # Pick your license as you wish (should match "license" above)
        'License :: OSI Approved :: GNU Lesser General Public License v3 (LGPLv3)',  # noqa: E501

        # Specify the Python versions you support here. In particular, ensure
        # that you indicate whether you support Python 2, Python 3 or both.
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.5'
    ],

    # What does your project relate to?
    keywords='nefis file_format',

    # You can just specify the packages manually here if your project is
    # simple. Or you can use find_packages().
    packages=find_packages(exclude=['contrib', 'docs', 'tests*']),
    cmdclass=cmdclass,
    ext_modules=ext_modules,
    # List run-time dependencies here.  These will be installed by pip when your
    # project is installed. For an analysis of "install_requires" vs pip's
    # requirements files see:
    # https://packaging.python.org/en/latest/technical.html#install-requires-vs-requirements-files
    install_requires=requirements,

    include_dirs=[np.get_include()],         # <---- New line

    # hmm, where did the data go?
    # data_files=[('nefis_data', ['data/trim-f34.dat', 'data/trim-f34.def'])],

    # To provide executable scripts, use entry points in preference to the
    # "scripts" keyword. Entry points provide cross-platform support and allow
    # pip to create the appropriate form of executable for the target platform.
    entry_points={
        'console_scripts': [
            # TODO: check if you prefer this interface
            'nefis=nefis.cli:cli'
        ],
    },
)
