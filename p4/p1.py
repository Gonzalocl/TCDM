#!/bin/env python2

from __future__ import print_function, division
from pyspark.sql import SparkSession
import sys

'''
Para ejecutar este script en local uso el siguiente comando,
los ficheros de datos deben de estar descomprimidos en la misma
carpeta que el script.

spark-submit \
  --master local[*] \
  --num-executors 4 \
  --driver-memory 4g \
  p1.py \
  cite75_99.txt \
  apat63_99.txt \
  dfCitas.parquet \
  dfInfo.parquet
'''

'''
Para ejecutar este script en YARN uso el siguiente comando,
los ficheros de datos deben de estar descomprimidos y en HDFS en
la carpeta patentes.

spark-submit \
  --master yarn \
  --num-executors 8 \
  --driver-memory 4g \
  --queue urgent \
  p1.py \
  patentes/cite75_99.txt \
  patentes/apat63_99.txt \
  dfCitas.parquet \
  dfInfo.parquet
'''

def main():

    if len(sys.argv) != 5:
        print('Usar: {} cite75_99.txt apat63_99.txt dfCitas.parquet dfInfo.parquet'.format(sys.argv[0]))
        exit(-1)

    spark = SparkSession.builder.appName('Practica 1 de Gonzalo').getOrCreate()
    spark.sparkContext.setLogLevel('FATAL')

    cite = spark \
        .read \
        .option('inferSchema', 'true') \
        .option('header', 'true') \
        .csv(sys.argv[1])

    cite = cite.groupBy('CITED') \
        .count() \
        .selectExpr('CITED as NPatente', 'count as ncitas')

    cite.write.format('parquet') \
        .mode('overwrite') \
        .option('compression', 'gzip') \
        .save(sys.argv[3])

    print('Numero de particiones de cite: {}'.format(cite.rdd.getNumPartitions()))

    apat = spark \
        .read \
        .option('inferSchema', 'true') \
        .option('header', 'true') \
        .csv(sys.argv[2])

    apat = apat.selectExpr('PATENT as NPatente',
                           'COUNTRY as Pais',
                           'GYEAR as Anho')

    apat.write.format('parquet') \
        .mode('overwrite') \
        .option('compression', 'gzip') \
        .save(sys.argv[4])

    print('Numero de particiones de apat: {}'.format(apat.rdd.getNumPartitions()))

if __name__ == '__main__':
    main()
