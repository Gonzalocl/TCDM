
```bash
# download patentes.tar.gz
tar xvzf patentes.tar.gz
hdfs dfs -put patentes .
hdfs dfs -ls -R
```

```bash
module load maven
cd 01-citingpatents
rm -rf out01; hdfs dfs -rm -r -f out01
mvn package
yarn jar target/citingpatents-0.0.1-SNAPSHOT.jar -Dmapred.job.queue.name=urgent patentes/cite75_99.txt out01
hdfs dfs -get out01
gzip -d out01/*.gz
```

```bash
module load maven
cp 01-citingpatents/target/citingpatents-0.0.1-SNAPSHOT.jar 02-citationnumberbypatent_chained/src/resources
cd 02-citationnumberbypatent_chained
rm -rf out02; hdfs dfs -rm -r -f out02
mvn package
export HADOOP_CLASSPATH="./src/resources/citingpatents-0.0.1-SNAPSHOT.jar"
yarn jar target/citationnumberbypatent_chained-0.0.1-SNAPSHOT.jar -Dmapred.job.queue.name=urgent -libjars $HADOOP_CLASSPATH patentes/cite75_99.txt out02
hdfs dfs -get out02
```

```bash
module load maven
cd 03-creasequencefile
rm -rf out03; hdfs dfs -rm -r -f out03
mvn package
yarn jar target/creasequencefile-0.0.1-SNAPSHOT.jar -Dmapred.job.queue.name=urgent -files ../patentes/country_codes.txt patentes/apat63_99.txt out03
hdfs dfs -text out03/part-m-* > out03
```

```bash
cd 04-python
rm -rf out04; hdfs dfs -rm -r -f out04
yarn jar \
  /opt/cloudera/parcels/CDH-6.1.1-1.cdh6.1.1.p0.875250/lib/hadoop-mapreduce/hadoop-streaming.jar \
  -D mapred.job.queue.name=urgent \
  -D mapreduce.job.reduces=2 \
  -files mapper.py,reducer.py \
  -input patentes/apat63_99.txt \
  -output out04 \
  -mapper mapper.py \
  -reducer reducer.py
hdfs dfs -get out04
```
