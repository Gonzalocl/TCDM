
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
yarn jar target/citationnumberbypatent_chained-0.0.1-SNAPSHOT.jar -libjars $HADOOP_CLASSPATH patentes/cite75_99.txt out02
hdfs dfs -get out02
```
