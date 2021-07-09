#!/bin/env python2

from __future__ import print_function, division

import os.path

from pyspark import SparkFiles
from pyspark.sql import SparkSession
import pyspark.sql.functions as F
import sys

'''
Para ejecutar este este script en local uso el siguiente comando,
los ficheros de datos deben de en la misma carpeta que el script.

spark-submit \
  --master local[*] \
  --num-executors 4 \
  --driver-memory 4g \
  --files country_codes.txt \
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
  --files country_codes.txt \
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

    country_codes_path = os.path.basename(SparkFiles.get(sys.argv[3]))
    country_codes = {}

    with open(country_codes_path) as country_codes_file:
        for country_code in country_codes_file.readlines():
            (code, country) = country_code.strip().split('\t')
            country_codes[code] = country

    ccb = spark.sparkContext.broadcast(country_codes)

    data = cite.join(apat, 'NPatente', 'inner')

    aggregates = data.groupBy(['Pais', 'Anho']).agg(F.count(data.NPatente).alias('NumPatentes'),
                                                    F.sum(data.ncitas).alias('TotalCitas'),
                                                    F.avg(data.ncitas).alias('MediaCitas'),
                                                    F.max(data.ncitas).alias('MaxCitas'))

    aggregates = aggregates.withColumn('Pais', F.udf(lambda x: ccb.value.get(x))(aggregates.Pais))
    aggregates = aggregates.sort(aggregates.Pais, aggregates.Anho)

    aggregates.write.csv(sys.argv[4], header=True)

if __name__ == '__main__':
    main()
