---
title: Programación en Apache PySpark
author: Gonzalo Caparrós Laiz (`gonzalo.caparrosl@um.es`)
date: Junio 2021
geometry: margin=3cm
output: pdf_document
lang: es
---

\pagebreak

# Tarea 1: Extraer información

En primer lugar la preparación de todas las tareas de esta práctica, copio los ficheros de datos a HDFS con los siguientes comandos.

```bash
# download patentes.tar.gz
tar xvzf patentes.tar.gz
hdfs dfs -put patentes .
hdfs dfs -ls -R
```

![](img/img000.png)

Para esta primera tarea he hecho el script `p1.py`.
Con las siguientes líneas de código leo los ficheros de datos en csv a un dataframe.

```python
cite = spark \
    .read \
    .option('inferSchema', 'true') \
    .option('header', 'true') \
    .csv(sys.argv[1])

apat = spark \
    .read \
    .option('inferSchema', 'true') \
    .option('header', 'true') \
    .csv(sys.argv[2])
```

A continuación con la función `selectExpr` me quedo con las columnas que me interesan y las renombro al nombre indicado.
En el caso del dataframe `cite` primor agrupo las filas por la columna _CITED_ y cuento las filas de cada grupo.

```python
cite = cite.groupBy('CITED') \
    .count() \
    .selectExpr('CITED as NPatente', 'count as ncitas')

apat = apat.selectExpr('PATENT as NPatente',
                       'COUNTRY as Pais',
                       'GYEAR as Anho')
```

Una vez tengo los datos necesarios los guardo en formato parquet, con compresión.

```python
cite.write.format('parquet') \
    .mode('overwrite') \
    .option('compression', 'gzip') \
    .save(sys.argv[3])

apat.write.format('parquet') \
    .mode('overwrite') \
    .option('compression', 'gzip') \
    .save(sys.argv[4])
```

Por último muestro el número de particiones del RDD de ambos dataframes con la función `getNumPartitions`.

```python
print('Numero de particiones de cite: {}'.format(cite.rdd.getNumPartitions()))
print('Numero de particiones de apat: {}'.format(apat.rdd.getNumPartitions()))
```

Para ejecutar esta tarea uso los siguientes comandos, en primer lugar se borran los directorios de salida para salida y luego se ejecuta el comando `spark-submit`.

```bash
hdfs dfs -rm -r -f -skipTrash dfCitas.parquet dfInfo.parquet

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
```

![](img/img001.png)

Con los siguientes comandos compruebo canutos ficheros se han generado en los directorios de salida.

```bash
hdfs dfs -ls dfInfo.parquet | head
hdfs dfs -ls dfCitas.parquet | head
```

![](img/img002.png)

Como podemos ver en el resumen de la salida de los comandos anteriores se crearon 16 archivos en la carpeta de salida donde se guardó el dataframe con las patentes con el código de pais.
Y en el caso del dataframe donde se cuentan las citas se crearon 201 archivos.

Como podemos comprobar, comparando con la salida del script de esta tarea, se crearon un archivo por cada partición más un archivo con el nombre `_SUCCESS`.

# Tarea 2: Contar patentes, total media máximo citas

```bash
rm -rf p2out; hdfs dfs -rm -r -f -skipTrash p2out

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

hdfs dfs -get p2out
cat p2out/* | head
```

# Tarea 3: Contar patentes usando RDDs 

```bash
rm -rf p3out; hdfs dfs -rm -r -f -skipTrash p3out

spark-submit \
  --master yarn \
  --num-executors 8 \
  --driver-memory 4g \
  --queue urgent \
  p3.py \
  patentes/apat63_99.txt \
  p3out

hdfs dfs -get p3out
cat p3out/* | head
```
