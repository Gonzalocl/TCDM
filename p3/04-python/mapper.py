#!/usr/bin/env python
import sys

for line in sys.stdin:
    fields = line[:-1].split(',')
    country = fields[4]
    claims = fields[8]
    if country == '"COUNTRY"':
        continue
    print('{}\t{}'.format(country, claims))
