#!/usr/bin/env python3
import rpncc
from sys import argv
from os import remove
import subprocess

if len(argv) != 2:
    print("INVALID ARGUMENTS")
rpncc.compile(argv + ["rpncc.out", "asm2"])
subprocess.run(["./rpncc.out"])
remove("rpncc.out")