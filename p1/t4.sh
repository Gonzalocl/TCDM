
# Not intended to be run as scripts if not running each command one by one

docker container exec -ti namenode /bin/bash
su - hdadmin
hdfs dfsadmin -printTopology
# screenshot
hdfs --daemon stop namenode
echo "172.18.0.3 /rack1
172.18.0.4 /rack1
172.18.0.5 /rack2
172.18.0.7 /rack2" > $HADOOP_HOME/etc/hadoop/topology.data
echo '#!/bin/bash

HADOOP_CONF=$HADOOP_HOME/etc/hadoop
while [ $# -gt 0 ] ; do
  nodeArg=$1
  exec< ${HADOOP_CONF}/topology.data
  result=""
  while read line ; do
    ar=( $line )
    if [ "${ar[0]}" = "$nodeArg" ] ; then
      result="${ar[1]}"
    fi
  done
  shift
  if [ -z "$result" ] ; then
    echo -n "/default-rack "
  else
    echo -n "$result "
  fi
done' > $HADOOP_HOME/etc/hadoop/topology.script
chmod +x $HADOOP_HOME/etc/hadoop/topology.script

hadoop_conf_backup_folder="hadoop_conf_backup"
mkdir -p "$hadoop_conf_backup_folder"

hadoop_conf_file="core-site.xml"
cp "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file" "$hadoop_conf_backup_folder"
head -n -1 "$hadoop_conf_backup_folder/$hadoop_conf_file" > "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"
echo '  <property>
    <name>net.topology.script.file.name</name>
    <value>/opt/bd/hadoop/etc/hadoop/topology.script</value>
    <final>true</final>
  </property>
</configuration>' >> "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"

hdfs --daemon start namenode
hdfs dfsadmin -printTopology
# screenshot
exit
exit
