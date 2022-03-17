# coding=utf-8
# Copyright (c) HISSL Contributors

import pathlib

from typing import List


def txt_of_paths_to_list(path: pathlib.Path) -> List[pathlib.Path]:
    """Reads a .txt file with a path per row and returns a list of paths"""
    content: List = []
    with open(path, "r") as f:
        while line := f.readline().rstrip():
            content.append(pathlib.Path(line))
    return content
