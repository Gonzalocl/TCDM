#!/bin/env python2

from __future__ import print_function, division
from pyspark.sql import SparkSession
import pyspark.sql.functions as F
import sys

# spark-submit --master local[*] --num-executors 4 --driver-memory 4g p1.py cite75_99.txt apat63_99.txt dfCitas.parquet dfInfo.parquet

def main():
    if len(sys.argv) != 5:
        print('Usar: {} cite75_99.txt apat63_99.txt dfCitas.parquet dfInfo.parquet'.format(sys.argv[0]))
        exit(-1)

    spark = SparkSession.builder.appName('Practica 1 de Gonzalo').getOrCreate()
    spark.sparkContext.setLogLevel('FATAL')

    cite = spark\
        .read\
        .option('inferSchema', 'true')\
        .option('header', 'true')\
        .csv(sys.argv[1])

    cite.groupBy('CITED').count().selectExpr('CITED as NPatente', 'count as ncitas').show()

    apat = spark\
        .read\
        .option('inferSchema', 'true')\
        .option('header', 'true')\
        .csv(sys.argv[2])

    apat.selectExpr('PATENT as NPatente', 'COUNTRY as Pais', 'GYEAR as Anho').show()

if __name__ == '__main__':
    main()
