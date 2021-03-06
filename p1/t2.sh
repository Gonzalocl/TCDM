
# Not intended to be run as scripts if not running each command one by one

docker container exec -ti namenode /bin/bash
su - hdadmin
touch ${HADOOP_HOME}/etc/hadoop/dfs.include \
  ${HADOOP_HOME}/etc/hadoop/dfs.exclude \
  ${HADOOP_HOME}/etc/hadoop/yarn.include \
  ${HADOOP_HOME}/etc/hadoop/yarn.exclude

echo "datanode1
datanode2
datanode3
datanode4" > ${HADOOP_HOME}/etc/hadoop/dfs.include

echo "datanode1
datanode2
datanode3
datanode4" > ${HADOOP_HOME}/etc/hadoop/yarn.include

hadoop_conf_backup_folder="hadoop_conf_backup"
mkdir -p "$hadoop_conf_backup_folder"

hadoop_conf_file="hdfs-site.xml"
cp "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file" "$hadoop_conf_backup_folder"
head -n -1 "$hadoop_conf_backup_folder/$hadoop_conf_file" > "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"
echo '  <property>
    <name>dfs.hosts</name>
    <value>/opt/bd/hadoop/etc/hadoop/dfs.include</value>
    <final>true</final>
  </property>
  <property>
    <name>dfs.hosts.exclude</name>
    <value>/opt/bd/hadoop/etc/hadoop/dfs.exclude</value>
    <final>true</final>
  </property>
</configuration>' >> "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"


hadoop_conf_file="yarn-site.xml"
cp "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file" "$hadoop_conf_backup_folder"
head -n -1 "$hadoop_conf_backup_folder/$hadoop_conf_file" > "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"
echo '  <property>
    <name>yarn.resourcemanager.nodes.include-path</name>
    <value>/opt/bd/hadoop/etc/hadoop/yarn.include</value>
    <final>true</final>
  </property>
  <property>
    <name>yarn.resourcemanager.nodes.exclude-path</name>
    <value>/opt/bd/hadoop/etc/hadoop/yarn.exclude</value>
    <final>true</final>
  </property>
</configuration>' >> "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"

yarn --daemon stop resourcemanager
hdfs --daemon stop namenode
hdfs --daemon start namenode
yarn --daemon start resourcemanager

cat hadoop/logs/hadoop-hdadmin-namenode-namenode.log
# screenshot
cat hadoop/logs/hadoop-hdadmin-resourcemanager-namenode.log
# screenshot

echo "datanode5" >> ${HADOOP_HOME}/etc/hadoop/yarn.include
yarn rmadmin -refreshNodes
# new terminal
docker container run -d --name datanode5 --network=hadoop-cluster --hostname datanode5 --cpus=1 --memory=3072m \
  --expose 8000-10000 --expose 50000-50200 datanode-image /inicio.sh
# previous terminal
hdfs dfsadmin -report
# screenshot
yarn node -list
# screenshot
echo "datanode5" >> ${HADOOP_HOME}/etc/hadoop/dfs.include
hdfs dfsadmin -refreshNodes
hdfs dfsadmin -report
# screenshot
yarn node -list
# screenshot
# http://localhost:8088/cluster/nodes
# screenshot
# http://localhost:9870/dfshealth.html#tab-datanode
# screenshot
hdfs balancer
# screenshot
exit
exit
