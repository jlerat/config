#!/usr/bin/env python
# -*- coding: utf-8 -*-

## -- Script Meta Data --
## Author  : ler015
## Created : 2021-09-03 18:09:31.811068
## Comment : Download monthly SILO data
##
## ------------------------------


import sys, os, re, json, math
import argparse
from pathlib import Path
from itertools import product as prod
import requests
#import warnings
#warnings.filterwarnings("ignore")

import numpy as np
import pandas as pd

from datetime import datetime
from dateutil.relativedelta import relativedelta as delta

from hydrodiy.io import csv, iutils

from tqdm import tqdm

#----------------------------------------------------------------------
# Config
#----------------------------------------------------------------------
variables = ["et_morton_potential"]
period = [1965, 1965]

url_base = "https://s3-ap-southeast-2.amazonaws.com/silo-open-data"+\
                "/annual/{varname}/{year}.{varname}.nc"

chunk_size = 1024

#----------------------------------------------------------------------
# Folders
#----------------------------------------------------------------------
source_file = Path(__file__).resolve()
froot = source_file.parent

fdata = {}
for varname in variables:
    f = froot / varname
    f.mkdir(exist_ok=True, parents=True)
    fdata[varname] = f

basename = source_file.stem
LOGGER = iutils.get_logger(basename)

#----------------------------------------------------------------------
# Process
#----------------------------------------------------------------------

for year, varname in prod(range(period[0], period[1]+1), variables):
    LOGGER.info(f"dealing with {year}-{varname}")

    url = url_base.format(year=year, varname=varname)
    fname = fdata[varname] / url.split('/')[-1]
    if fname.exists():
        continue

    with requests.get(url, stream=True) as resp:
        resp.raise_for_status()
        total = int(resp.headers.get('content-length', 0))
        with fname.open("wb") as file, \
                tqdm(desc=fname.stem,
                        total=total,
                        unit='iB',
                        unit_scale=True,
                        unit_divisor=chunk_size) as bar:
            for data in resp.iter_content(chunk_size=chunk_size):
                size = file.write(data)
                bar.update(size)

LOGGER.info("Process completed")

