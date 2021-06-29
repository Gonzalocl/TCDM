
# Not intended to be run as scripts if not running each command one by one

# download CopyHalfFile.zip
unzip CopyHalfFile.zip
# edit CopyHalfFile
docker cp CopyHalfFile namenode:/home/luser
docker container exec -ti namenode /bin/bash
chown -R luser:luser /home/luser/CopyHalfFile
su - luser
cd CopyHalfFile
mvn package
cd target; hadoop jar hdfs-0.0.1-SNAPSHOT.jar text_file0.txt out0.txt
hdfs dfs -cat out.txt
exit
exit
