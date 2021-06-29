
# Not intended to be run as scripts if not running each command one by one

# download FileSystemCat.zip
unzip FileSystemCat.zip
docker cp FileSystemCat namenode:/home/luser
docker container exec -ti namenode /bin/bash
chown -R luser:luser /home/luser/FileSystemCat
su - luser
echo "aaaa
bbbb
cccc
dddd" > text_file.txt
hdfs dfs -put text_file.txt .
cd FileSystemCat
mvn package
cd target; hadoop jar hdfs-0.0.1-SNAPSHOT.jar text_file.txt
exit
exit