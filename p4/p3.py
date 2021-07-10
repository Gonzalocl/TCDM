#!/bin/env python2

from __future__ import print_function, division

from pyspark.sql import SparkSession
from collections import defaultdict
import sys

'''
Para ejecutar este script en local uso el siguiente comando,
los ficheros de datos deben de en la misma carpeta que el script.

spark-submit \
  --master local[*] \
  --num-executors 4 \
  --driver-memory 4g \
  p3.py \
  apat63_99.txt \
  p3out
'''

'''
Para ejecutar este script en YARN uso el siguiente comando,
los ficheros de datos deben de estar en HDFS.

spark-submit \
  --master yarn \
  --num-executors 8 \
  --driver-memory 4g \
  --queue urgent \
  p3.py \
  patentes/apat63_99.txt \
  p3out
'''

def count_years(years):
    years_count = defaultdict(int)
    for year in years:
        years_count[year] += 1
    return list(sorted(years_count.items()))

def main():

    if len(sys.argv) != 3:
        print('Usar: {} apat63_99.txt p3out'.format(sys.argv[0]))
        exit(-1)

    spark = SparkSession.builder.appName('Practica 3 de Gonzalo').getOrCreate()
    spark.sparkContext.setLogLevel('FATAL')
    sc = spark.sparkContext

    apat = sc.textFile(sys.argv[1], 8)
    country_year = apat.map(lambda x: (x.split(',')[4][1:-1], x.split(',')[1]))
    patents_year = country_year.groupByKey().mapValues(count_years).sortByKey()
    patents_year.saveAsTextFile(sys.argv[2])

if __name__ == '__main__':
    main()
