#!/usr/bin/env python
import sys

for line in sys.stdin:
    print('{}\t{}'.format(0, line.strip()))
