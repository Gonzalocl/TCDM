
```bash
# download patentes.tar.gz
tar xvzf patentes.tar.gz
hdfs dfs -put patentes .
hdfs dfs -ls -R

module load maven
cd 01-citingpatents
rm -rf out; hdfs dfs -rm -r -f out
mvn package
yarn jar target/citingpatents-0.0.1-SNAPSHOT.jar -Dmapred.job.queue.name=urgent patentes/cite75_99.txt out
hdfs dfs -get out
gzip -d out/*.gz
```