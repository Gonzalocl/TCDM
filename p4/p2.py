#!/bin/env python2

from __future__ import print_function, division
from pyspark.sql import SparkSession
import sys

'''
Para ejecutar este este script en local uso el siguiente comando,
los ficheros de datos deben de en la misma carpeta que el script.

spark-submit \
  --master local[*] \
  --num-executors 4 \
  --driver-memory 4g \
  p2.py \
  dfCitas.parquet \
  dfInfo.parquet \
  country_codes.txt \
  p2out
'''

'''
Para ejecutar este script en YARN uso el siguiente comando,
los ficheros de datos deben de estar en HDFS menos el fichero
country_codes.txt que debe de estar en local.

spark-submit \
  --master yarn \
  --num-executors 8 \
  --driver-memory 4g \
  --queue urgent \
  p2.py \
  dfCitas.parquet \
  dfInfo.parquet \
  country_codes.txt \
  p2out
'''

def main():

    if len(sys.argv) != 5:
        print('Usar: {} dfCitas.parquet dfInfo.parquet country_codes.txt p2out'.format(sys.argv[0]))
        exit(-1)

    spark = SparkSession.builder.appName('Practica 2 de Gonzalo').getOrCreate()
    spark.sparkContext.setLogLevel('FATAL')

    cite = spark \
        .read \
        .format('parquet') \
        .option('mode', 'FAILFAST') \
        .load(sys.argv[1])

    apat = spark \
        .read \
        .format('parquet') \
        .option('mode', 'FAILFAST') \
        .load(sys.argv[2])

if __name__ == '__main__':
    main()
