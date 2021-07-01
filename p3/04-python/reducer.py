#!/usr/bin/env python
import sys

last_key = None
count = 0
total = 0

for line in sys.stdin:

    key_value = line[:-1].split('\t')
    key = key_value[0]
    value = int(key_value[1]) if key_value[1].isnumeric() else 0

    if last_key and last_key != key:

        print('{}\t{}'.format(last_key, total/count))

        last_key = key
        count = 1
        total = value

    else:

        last_key = key
        count += 1
        total += value

if last_key:
    print('{}\t{}'.format(last_key, total/count))
