#!/usr/bin/env python

"""
setup.py file for GridDB python client
"""

from distutils.command.build import build
import os

try:
    from setuptools import setup, Extension
except ImportError:
    from distutils.core import setup, Extension

try:
    with open('README.rst') as f:
        readme = f.read()
except IOError:
    readme = ''

os.environ["CXX"] = "g++"
os.environ["CC"] = "g++"

SOURCES = [
    'src/AggregationResult.cpp',
    'src/Container.cpp',
    'src/ContainerInfo.cpp',
    'src/Field.cpp',
    'src/PartitionController.cpp',
    'src/Query.cpp',
    'src/QueryAnalysisEntry.cpp',
    'src/RowKeyPredicate.cpp',
    'src/RowList.cpp',
    'src/RowSet.cpp',
    'src/Store.cpp',
    'src/StoreFactory.cpp',
    'src/TimeSeriesProperties.cpp',
    'src/TimestampUtils.cpp',
    'src/griddb.i',
    'src/Util.cpp'
]

DEPENDENTS = [
    'src/AggregationResult.h',
    'src/ContainerInfo.h',
    'src/Container.h',
    'src/ExpirationInfo.h',
    'src/Field.h'
    'src/GSException.h',
    'src/PartitionController.h',
    'src/Query.h',
    'src/QueryAnalysisEntry.h',
    'src/RowKeyPredicate.h',
    'src/RowList.h',
    'src/RowSet.h',
    'src/Store.h',
    'src/StoreFactory.h',
    'src/TimeSeriesProperties.h',
    'src/TimestampUtils.h',
    'src/gstype_python.i',
    'src/gstype.i',
    'src/Util.h',
    'include/gridstore.h'
]

INCLUDES = [
    'include',
    'src',
    os.environ['HOME'] + '/.pyenv/versions/3.10.4/lib/python3.10/site-packages/numpy/core/include/'
]

COMPILE_ARGS = [
    '-std=c++0x'
]

LIBRARIES = [
    'gridstore'
]

SWIG_OPTS = [
    '-DSWIGWORDSIZE64',
    '-c++',
    '-outdir',
    '.',
    '-Isrc'
]


class CustomBuild(build):
    sub_commands = [
        ('build_ext', build.has_ext_modules),
        ('build_py', build.has_pure_modules),
        ('build_clib', build.has_c_libraries),
        ('build_scripts', build.has_scripts)
    ]


griddb_module = Extension('_griddb_python',
                          sources=SOURCES,
                          include_dirs=INCLUDES,
                          libraries=LIBRARIES,
                          extra_compile_args=COMPILE_ARGS,
                          swig_opts=SWIG_OPTS,
                          depends=DEPENDENTS
                          )

classifiers = [
    "License :: OSI Approved :: Apache Software License",
    "Operating System :: MacOS :: MacOS X",
    "Programming Language :: Python :: 3.10"
]

cclient_version = "5.0.0"

setup(name='griddb_python',
      version='0.8.5',
      author='Katsuhiko Nonomura',
      author_email='contact@griddb.org',
      description='GridDB Python Client Library built using SWIG',
      long_description=readme,
      ext_modules=[griddb_module],
      py_modules=['griddb_python'],
	data_files=[
            (
                os.path.join(
                    "lib/python3.10/site-packages/griddb/griddb-c-client", cclient_version
                ),
                [
                    os.path.join("griddb-c-client", cclient_version, "LICENSE"),
                    os.path.join("griddb-c-client", cclient_version, "README.md"),
                ],
            ),
            (
                os.path.join(
                    "lib/python3.10/site-packages/griddb/griddb-c-client",
                    cclient_version,
                    "3rd_party",
                ),
                [
                    os.path.join(
                        "griddb-c-client", cclient_version, "3rd_party/3rd_party.md"
                    ),
                    os.path.join(
                        "griddb-c-client",
                        cclient_version,
                        "3rd_party/Apache_License-2.0.txt",
                    ),
                    os.path.join(
                        "griddb-c-client", cclient_version, "3rd_party/BSD_License.txt"
                    ),
                    os.path.join(
                        "griddb-c-client", cclient_version, "3rd_party/MIT_License.txt"
                    ),
                ],
            ),
            (
                os.path.join(
                    "lib/python3.10/site-packages/griddb/griddb-c-client",
                    cclient_version,
                    "3rd_party/ebb",
                ),
                [os.path.join("griddb-c-client", cclient_version, "3rd_party/ebb/LICENSE")],
            ),
            (
                os.path.join(
                    "lib/python3.10/site-packages/griddb/griddb-c-client",
                    cclient_version,
                    "3rd_party/omaha",
                ),
                [
                    os.path.join(
                        "griddb-c-client", cclient_version, "3rd_party/omaha/COPYING"
                    )
                ],
            ),
            (
                os.path.join(
                    "lib/python3.10/site-packages/griddb/griddb-c-client",
                    cclient_version,
                    "3rd_party/picojson",
                ),
                [
                    os.path.join(
                        "griddb-c-client", cclient_version, "3rd_party/picojson/include/README.mkdn"
                    )
                ],
            ),
            (
                os.path.join(
                    "lib/python3.10/site-packages/griddb/griddb-c-client",
                    cclient_version,
                    "3rd_party/purewell",
                ),
                [
                    os.path.join(
                        "griddb-c-client",
                        cclient_version,
                        "3rd_party/purewell/purewell.txt",
                    )
                ],
            ),
            (
                os.path.join(
                    "lib/python3.10/site-packages/griddb/griddb-c-client",
                    cclient_version,
                    "3rd_party/sha2",
                ),
                [os.path.join("griddb-c-client", cclient_version, "3rd_party/sha2/README")],
            ),
            (
                os.path.join(
                    "lib/python3.10/site-packages/griddb/griddb-c-client",
                    cclient_version,
                    "3rd_party/uuid",
                ),
                [
                    os.path.join(
                        "griddb-c-client", cclient_version, "3rd_party/uuid/uuid/COPYING"
                    )
                ],
            ),
            (
                os.path.join(
                    "lib/python3.10/site-packages/griddb/griddb-c-client",
                    cclient_version,
                    "3rd_party/yield",
                ),
                [
                    os.path.join(
                        "griddb-c-client", cclient_version, "3rd_party/yield/yield.txt"
                    )
                ],
            ),
            (
                "lib/python3.10/site-packages",
                [
                    os.path.join(
                        "griddb-c-client", cclient_version, "lib/libgridstore.0.dylib"
                    ),
                    os.path.join("griddb-c-client", cclient_version, "lib/libgridstore.a"),
                    os.path.join(
                        "griddb-c-client", cclient_version, "lib/libgridstore.dylib"
                    ),
                ],
            ),
            (
                os.path.join(
                    "lib/python3.10/site-packages/griddb/griddb-c-client",
                    cclient_version,
                    "include",
                ),
                [os.path.join("griddb-c-client", cclient_version, "include/gridstore.h")],
            ),
            (
                os.path.join("lib/python3.10/site-packages/griddb/Sample"),
                ["sample/sample1.py"],
            ),
        ],
      url='https://github.com/griddb/python_client/',
      license='Apache Software License',
      cmdclass={'build': CustomBuild},
      long_description_content_type = 'text/x-rst',
      classifiers=classifiers
    )
