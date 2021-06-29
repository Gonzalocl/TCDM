
# Not intended to be run as scripts if not running each command one by one

docker container exec -ti namenode /bin/bash
su - hdadmin
hdfs fsck /
# screenshot
# new terminal
docker container stop datanode2 datanode3
# close terminal
hdfs dfsadmin -report
# screenshot
hdfs fsck /
# screenshot
hdfs dfs -get /user/luser/libros/random_words.txt.bz2
sha1sum random_words.txt.bz2
# screenshot
# new terminal
docker container run -d --name datanode6 --network=hadoop-cluster --hostname datanode6 --cpus=1 --memory=3072m \
  --expose 8000-10000 --expose 50000-50200 datanode-image /inicio.sh
echo "datanode6" >> ${HADOOP_HOME}/etc/hadoop/yarn.include
echo "datanode6" >> ${HADOOP_HOME}/etc/hadoop/dfs.include
yarn rmadmin -refreshNodes
hdfs dfsadmin -refreshNodes
# close terminal
hdfs dfsadmin -report
# screenshot
yarn node -list
# screenshot
hdfs fsck /
# screenshot
exit
exit
