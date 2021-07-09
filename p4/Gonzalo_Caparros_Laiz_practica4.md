---
title: Programación en Apache PySpark
author: Gonzalo Caparrós Laiz (`gonzalo.caparrosl@um.es`)
date: Junio 2021
geometry: margin=3cm
output: pdf_document
lang: es
---

\pagebreak

```bash
# download patentes.tar.gz
tar xvzf patentes.tar.gz
hdfs dfs -put patentes .
hdfs dfs -ls -R
```

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

```bash
hdfs dfs -ls dfInfo.parquet | head
hdfs dfs -ls dfCitas.parquet | head
```

```bash
rm -rf p2out; hdfs dfs -rm -r -f p2out

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
