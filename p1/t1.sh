
# Not intended to be run as scripts if not running each command one by one

docker container exec -ti namenode /bin/bash
ls /var/data/hdfs/namenode/current
exit
# screenshot
docker container run -ti --name backupnode --network=hadoop-cluster --hostname backupnode --cpus=1 --memory=3072m --expose 50100 -p 50105:50105 hadoop-base /bin/bash
cd opt/bd
mkdir backup
mkdir -p backup/dfs/name
chown -R hdadmin backup
su - hdadmin

hadoop_conf_backup_folder="hadoop_conf_backup"
mkdir -p "$hadoop_conf_backup_folder"

hadoop_conf_file="core-site.xml"
cp "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file" "$hadoop_conf_backup_folder"
head -n -1 "$hadoop_conf_backup_folder/$hadoop_conf_file" > "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"
echo '  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://namenode:9000/</value>
    <final>true</final>
  </property>
  <property>
    <name>hadoop.tmp.dir</name>
    <value>/opt/bd/backup</value>
    <final>true</final>
  </property>
</configuration>' >> "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"

hadoop_conf_file="hdfs-site.xml"
cp "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file" "$hadoop_conf_backup_folder"
head -n -1 "$hadoop_conf_backup_folder/$hadoop_conf_file" > "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"
echo '  <property>
    <name>dfs.namenode.backup.address</name>
    <value>backupnode:50100</value>
    <final>true</final>
  </property>
  <property>
    <name>dfs.namenode.backup.http-address</name>
    <value>backupnode:50105</value>
    <final>true</final>
  </property>
</configuration>' >> "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"

hdfs namenode -backup
# screenshot

# new terminal
docker container exec -ti backupnode /bin/bash
su - hdadmin
find backup/
# screenshot
sha1sum backup/dfs/name/current/*
# screenshot
exit
exit
docker container exec -ti namenode /bin/bash
sha1sum /var/data/hdfs/namenode/current/*
# screenshot
exit
# close terminal

exit
exit

docker container exec -ti namenode /bin/bash
su - hdadmin
yarn --daemon stop resourcemanager
hadoop_conf_backup_folder="hadoop_conf_backup"
mkdir -p "$hadoop_conf_backup_folder"

hadoop_conf_file="yarn-site.xml"
cp "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file" "$hadoop_conf_backup_folder"
head -n -1 "$hadoop_conf_backup_folder/$hadoop_conf_file" > "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"
echo '  <property>
    <name>yarn.timeline-service.hostname</name>
    <value>timelineserver</value>
    <final>true</final>
  </property>
  <property>
    <name>yarn.timeline-service.enabled</name>
    <value>true</value>
    <final>true</final>
  </property>
  <property>
    <name>yarn.system-metrics-publisher.enabled</name>
    <value>true</value>
    <final>true</final>
  </property>
</configuration>' >> "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"

yarn --daemon start resourcemanager
exit
exit
docker container run -ti --name timelineserver --network=hadoop-cluster --hostname timelineserver --cpus=1 --memory=3072m --expose 10200 -p 8188:8188 hadoop-base /bin/bash
su - hdadmin
yarn --daemon start timelineserver
# http://localhost:8188/
# screenshot

# new terminal
docker container exec -ti namenode /bin/bash
su - hdadmin
export MAPRED_EXAMPLES=$HADOOP_HOME/share/hadoop/mapreduce
yarn jar $MAPRED_EXAMPLES/hadoop-mapreduce-examples-*.jar pi 16 1000
# screenshot
yarn jar $MAPRED_EXAMPLES/hadoop-mapreduce-examples-*.jar pi 16 1000
# screenshot
exit
exit
# close terminal

exit
exit
