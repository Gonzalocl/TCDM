
# Not intended to be run as scripts if not running each command one by one

docker container exec -ti namenode /bin/bash
su - hdadmin
echo "datanode4" > ${HADOOP_HOME}/etc/hadoop/dfs.exclude
echo "datanode4" > ${HADOOP_HOME}/etc/hadoop/yarn.exclude
hdfs dfsadmin -refreshNodes
yarn rmadmin -refreshNodes
# http://localhost:8088/cluster/nodes
# screenshot
# http://localhost:9870/dfshealth.html#tab-datanode
# screenshot
hdfs dfsadmin -report
# screenshot
yarn node -list
# screenshot
# new terminal
docker container stop namenode datanode4
# close terminal

echo "datanode1
datanode2
datanode3
datanode5" > ${HADOOP_HOME}/etc/hadoop/dfs.include

echo "datanode1
datanode2
datanode3
datanode5" > ${HADOOP_HOME}/etc/hadoop/yarn.include

echo > ${HADOOP_HOME}/etc/hadoop/dfs.exclude
echo > ${HADOOP_HOME}/etc/hadoop/yarn.exclude

hdfs dfsadmin -refreshNodes
yarn rmadmin -refreshNodes

exit
exit
