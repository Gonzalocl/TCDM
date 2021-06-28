
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
mkdir "$hadoop_conf_backup_folder"

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

