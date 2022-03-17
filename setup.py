#!/usr/bin/env python
"""The setup script."""

from setuptools import setup, find_packages
from typing import List

import ast


with open("hissl/__init__.py") as f:
    for line in f:
        if line.startswith("__version__"):
            version = ast.parse(line).body[0].value.s  # type: ignore
            break

with open("README.md") as readme_file:
    readme = readme_file.read()

with open("HISTORY.md") as history_file:
    history = history_file.read()

requirements: List[str] = []
setup_requirements: List[str] = [
    "pytest-runner",
]

test_requirements = [
    "pytest>=3",
]

setup(
    author="NKI AI for Oncology Lab",
    author_email="y.schirris@nki.nl",
    python_requires=">=3.6",
    classifiers=[
        "Development Status :: 2 - Pre-Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Natural Language :: English",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.5",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
    ],
    description="NKI-AI Boilerplate has the boilerplate you need to create a Python package.",
    entry_points={
        "console_scripts": [
            "hissl=hissl.cli.cli:main",
        ],
    },
    install_requires=requirements,
    license="MIT license",
    long_description=readme + "\n\n" + history,
    long_description_content_type="text/markdown",
    include_package_data=True,
    keywords="hissl",
    name="hissl",
    packages=find_packages(include=["hissl", "hissl.*"]),
    setup_requires=setup_requirements,
    test_suite="tests",
    tests_require=test_requirements,
    url="https://github.com/NKI-AI/hissl",
    version="0.0.1",
    zip_safe=False,
)
