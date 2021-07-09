#!/bin/env python2

from __future__ import print_function, division

from pyspark.sql import SparkSession
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

def main():

    if len(sys.argv) != 3:
        print('Usar: {} apat63_99.txt p3out'.format(sys.argv[0]))
        exit(-1)

    spark = SparkSession.builder.appName('Practica 3 de Gonzalo').getOrCreate()
    spark.sparkContext.setLogLevel('FATAL')
    sc = spark.sparkContext

    apat = sc.textFile(sys.argv[1], 8)
    print(apat.take(20))
    print(apat.getNumPartitions())

if __name__ == '__main__':
    main()
