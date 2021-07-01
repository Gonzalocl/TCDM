#!/usr/bin/env python
import sys

for line in sys.stdin:
    fields = line.strip().split(',')
    country = fields[4]
    claims = fields[8]
    print('{}\t{}'.format(country, claims))
