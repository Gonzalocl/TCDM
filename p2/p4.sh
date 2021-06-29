
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






exit
exit
