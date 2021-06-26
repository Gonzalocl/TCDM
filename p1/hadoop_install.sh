
docker container run -ti --name "hadoop-install" ubuntu:latest /bin/bash
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata && ln -fs /usr/share/zoneinfo/Europe/Madrid /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata
apt-get install -y --no-install-recommends openjdk-8-jdk python3 iputils-ping maven wget nano less locales
apt-get clean
locale-gen es_ES.UTF-8; update-locale LANG=es_ES.UTF-8
mkdir /opt/bd; cd /opt/bd
export HADOOP_VERSION=3.2.2
wget http://apache.rediris.es/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
wget https://dist.apache.org/repos/dist/release/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz.sha512
sha512sum hadoop-${HADOOP_VERSION}.tar.gz | cut -d ' ' -f 1
cut -d ' ' -f 1 hadoop-${HADOOP_VERSION}.tar.gz.sha512
tar xvzf hadoop-${HADOOP_VERSION}.tar.gz
ln -s hadoop-${HADOOP_VERSION} hadoop
rm hadoop-${HADOOP_VERSION}.tar.gz*
groupadd -r hadoop
useradd -r -g hadoop -d /opt/bd -s /bin/bash hdadmin
chown -R hdadmin:hadoop /opt/bd
adduser luser
adduser luser hadoop
su - hdadmin
cp /etc/skel/.* ~
echo '
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_HOME=/opt/bd/hadoop
export PATH=$PATH:$HADOOP_HOME/bin
' >> ~/.bashrc
. ~/.bashrc
hadoop version
exit
exit
docker container commit hadoop-install hadoop-base
docker images
docker container rm hadoop-install
