
# Not intended to be run as scripts if not running each command one by one

docker container exec -ti namenode /bin/bash
su - hdadmin
echo something > one_file
hdfs dfs -mkdir quota
hdfs dfsadmin -setQuota 4 quota
hdfs dfs -ls quota
hdfs dfs -put one_file quota/file_0
hdfs dfs -put one_file quota/file_1
hdfs dfs -put one_file quota/file_2
hdfs dfs -put one_file quota/file_3
hdfs dfs -put one_file quota/file_4
hdfs dfs -ls quota
# screenshot
exit
exit
# https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HdfsQuotaAdminGuide.html#Name_Quotas
