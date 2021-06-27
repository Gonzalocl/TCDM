
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

docker network create hadoop-cluster
docker container run -ti --name namenode --network=hadoop-cluster --hostname namenode --net-alias resourcemanager --expose 8000-10000 -p 9870:9870 -p 8088:8088 hadoop-base /bin/bash
mkdir -p /var/data/hdfs/namenode
chown hdadmin:hadoop /var/data/hdfs/namenode
su - hdadmin

hadoop_conf_backup_folder="hadoop_conf_backup"
mkdir "$hadoop_conf_backup_folder"
cp "$HADOOP_HOME/etc/hadoop/core-site.xml" \
  "$HADOOP_HOME/etc/hadoop/hdfs-site.xml" \
  "$HADOOP_HOME/etc/hadoop/yarn-site.xml" \
  "$HADOOP_HOME/etc/hadoop/mapred-site.xml" \
  "$hadoop_conf_backup_folder"

hadoop_conf_file="core-site.xml"
head -n -1 "$hadoop_conf_backup_folder/$hadoop_conf_file" > "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"
echo '  <property>
    <!-- Nombre del filesystem por defecto -->
    <!-- Como queremos usar HDFS tenemos que indicarlo con hdfs:// y el servidor y puerto en el que corre el NameNode -->
    <name>fs.defaultFS</name>
    <value>hdfs://namenode:9000/</value>
    <final>true</final>
  </property>
  <property>
    <!-- Directorio para almacenamiento temporal (debe tener suficiente espacio) -->
    <name>hadoop.tmp.dir</name>
    <value>/var/tmp/hadoop-${user.name}</value>
    <final>true</final>
  </property>
</configuration>' >> "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"

hadoop_conf_file="hdfs-site.xml"
head -n -1 "$hadoop_conf_backup_folder/$hadoop_conf_file" > "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"
echo ' <property>
   <!-- Factor de replicacion de los bloques -->
    <name>dfs.replication</name>
    <value>3</value>
    <final>true</final>
  </property>
  <property>
   <!-- Tamano del bloque (por defecto 128m) -->
    <name>dfs.blocksize</name>
    <value>64m</value>
    <final>true</final>
  </property>
  <property>
    <!-- Lista (separada por comas) de directorios donde el namenode guarda los metadatos. -->
    <name>dfs.namenode.name.dir</name>
    <value>file:///var/data/hdfs/namenode</value>
    <final>true</final>
  </property>
  <property>
    <!-- Dirección y puerto del interfaz web del namenode -->
    <name>dfs.namenode.http-address</name>
    <value>namenode:9870</value>
    <final>true</final>
  </property>
 </configuration>' >> "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"

hadoop_conf_file="yarn-site.xml"
head -n -1 "$hadoop_conf_backup_folder/$hadoop_conf_file" > "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"
echo '  <property>
    <!-- Nombre del equipo que ejecuta el demonio ResourceManager -->
    <name>yarn.resourcemanager.hostname</name>
    <value>resourcemanager</value>
    <final>true</final>
  </property>
  <property>
    <!-- Número máximo de vcores que un ApplicationMaster puede pedir al RM (por defecto: 4) -->
    <!-- Peticiones mayores lanzan una InvalidResourceRequestException -->
    <name>yarn.scheduler.maximum-allocation-vcores</name>
    <value>1</value>
    <final>true</final>
  </property>
  <property>
    <!-- Memoria minima (MB) que un ApplicationMaster puede solicitar al RM (por defecto: 1024) -->
    <!-- La memoria asignada a un contenedor será múltiplo de esta cantidad -->
    <name>yarn.scheduler.minimum-allocation-mb</name>
    <value>128</value>
    <final>true</final>
  </property>
  <property>
    <!-- Memoria maxima (MB) que un ApplicationMaster puede solicitar al RM (por defecto: 8192 MB) -->
    <!-- Peticiones mayores lanzan una InvalidResourceRequestException -->
    <!-- Puedes aumentar o reducir este valor en funcion de la memoria de la que dispongas -->
    <name>yarn.scheduler.maximum-allocation-mb</name>
    <value>2560</value>
    <final>true</final>
  </property>
</configuration>' >> "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"

hadoop_conf_file="mapred-site.xml"
head -n -1 "$hadoop_conf_backup_folder/$hadoop_conf_file" > "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"
echo '  <property>
    <!-- Framework que realiza el MapReduce -->
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
    <final>true</final>
  </property>

  <!-- Configuracion del ApplicationMaster (AM) del MR -->

  <property>
    <!-- Localizacion del software MR para el AM -->
    <name>yarn.app.mapreduce.am.env</name>
    <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>
  </property>

  <property>
    <!-- Numero maximo de cores para el ApplicationMaster (por defecto: 1) -->
    <name>yarn.app.mapreduce.am.resource.cpu-vcores</name>
    <value>1</value>
    <final>true</final>
  </property>

  <property>
    <!-- Memoria que necesita el ApplicationMaster del MR (por defecto: 1536) -->
    <name>yarn.app.mapreduce.am.resource.mb</name>
    <value>1536</value>
    <final>true</final>
  </property>


  <!-- Configuracion de los maps y reduces del MR -->

  <property>
    <!-- Ratio del tamaño del heap al tamaño del contenedor para las JVM (por defecto: 0.8)-->
    <name>mapreduce.job.heap.memory-mb.ratio</name>
    <value>0.8</value>
    <final>true</final>
  </property>

  <!-- Maps -->
  <property>
    <!-- Localizacion del software MR para los maps -->
    <name>mapreduce.map.env</name>
    <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>
  </property>

  <property>
    <!-- Numero maximo de cores para cada tarea map (por defecto: 1) -->
    <name>mapreduce.map.cpu.vcores</name>
    <value>1</value>
    <final>true</final>
  </property>

  <property>
    <!-- Opciones para las JVM de los maps -->
    <name>mapreduce.map.java.opts</name>
    <value>-Xmx1024M</value> <!-- Xmx define el tamaño máximo de la pila de Java -->
    <final>true</final>
  </property>

  <property>
    <!-- Memoria maxima (MB) por map (si -1 se optiene a partir de mapreduce.map.java.opts y mapreduce.job.heap.memory-mb.ratio) -->
    <name>mapreduce.map.memory.mb</name>
    <value>-1</value>
    <final>true</final>
  </property>

  <!-- Reduces -->
  <property>
    <!-- Localizacion del software MR para los reducers -->
    <name>mapreduce.reduce.env</name>
    <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>
  </property>

  <property>
    <!-- Numero maximo de cores para cada tarea reduce (por defecto: 1) -->
    <name>mapreduce.reduce.cpu.vcores</name>
    <value>1</value>
    <final>true</final>
  </property>

  <property>
    <!-- Opciones para las JVM de los reduces -->
    <name>mapreduce.reduce.java.opts</name>
    <value>-Xmx2048M</value> <!-- Xmx define el tamaño máximo de la pila de Java -->
    <final>true</final>
  </property>

  <property>
    <!-- Memoria maxima (MB) por reduce (si -1 se optiene a partir de mapreduce.map.java.opts y mapreduce.job.heap.memory-mb.ratio) -->
    <name>mapreduce.reduce.memory.mb</name>
    <value>-1</value>
    <final>true</final>
  </property>

</configuration>' >> "$HADOOP_HOME/etc/hadoop/$hadoop_conf_file"

hdfs namenode -format
ls /var/data/hdfs/namenode
ls $HADOOP_HOME/logs
hdfs --daemon start namenode
cat $HADOOP_HOME/logs/*
jps
yarn --daemon start resourcemanager
cat $HADOOP_HOME/logs/*
jps
# http://localhost:9870
# http://localhost:8088
yarn --daemon stop resourcemanager
hdfs --daemon stop namenode
exit
echo '#!/bin/bash
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_HOME=/opt/bd/hadoop
# Inicio el NameNode y el ResourceManager
su hdadmin -c "$HADOOP_HOME/bin/hdfs --daemon start namenode"
su hdadmin -c "$HADOOP_HOME/bin/yarn --daemon start resourcemanager"
# Lazo para mantener activo el contenedor
while true; do sleep 10000; done' > /inicio.sh
chmod +x /inicio.sh
exit
docker container commit namenode namenode-image
docker images
docker container rm namenode
