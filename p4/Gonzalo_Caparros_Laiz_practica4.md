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
