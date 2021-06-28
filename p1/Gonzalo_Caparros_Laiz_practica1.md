---
title: Instalación y despliegue de un cluster Hadoop 3
author: Gonzalo Caparrós Laiz (`gonzalo.caparrosl@um.es`)
date: Junio 2021
geometry: margin=3cm
output: pdf_document
lang: es
---

\pagebreak

# Tarea 1: Añadir al cluster un servidor de Backup y un TimeLineServer
## 1. Servidor de Backup

En la siguiente captura se puede ver al final el mensaje de que se ha realizado le checkpoint.  
![](img/img005.png)

A continuación se ve el contenido inicial de la carpeta de metadatos de NameNode.  
![](img/img000.png)

A continuación se ve el contenido inicial de la carpeta de backup de metadatos.  
![](img/img001.png)

En la siguiente captura se puede ver que se han copiado unos archivos a la carpeta de backup con nombres parecidos a los de la carpeta de metadatos.  
![](img/img002.png)

Se muestran los hashes de los archivos en la carpeta de backup.  
![](img/img003.png)

Se muestran los hashes de los archivos en la carpeta de metadatos.  
![](img/img004.png)

Como podemos ver en las capturas donde se muestran los hashes, los archivos con el mismo nombre son iguales porque se ha realizado el checkpoint.

\pagebreak

En las siguientes capturas se muestra la interfaz web del nodo de backup.  
![](img/img006.png)
![](img/img007.png)

\pagebreak

## 2. TimeLineServer

Las siguientes capturas son de la interfaz web del TimeLineServer:

- La primera no hay ninguna tarea en el historial.
- La segunda se ejecuta una vez cálculo de pi.
- La tercera es la segunda ejecución de cálculo de pi.

![img](img/img008.png)

![](img/img009.png)

![](img/img010.png)

\pagebreak

# Tarea 2: Añadir un nuevo DataNode/NodeManager

En la siguiente captura se ve en las líneas del log del namenode que se han incluido los ficheros.  
![](img/img011.png)

En la siguiente captura se ve en las líneas del log del resourcemanager que se han incluido los ficheros.  
![](img/img012.png)

El primer paso para añadir un nodo ha sido añadirlo al resourcemanager.

Para ello primero se añaden las propiedades `dfs.hosts` y `dfs.hosts.exclude` al archivo `hdfs-site.xml` para indicarle al namenode los ficheros.
Y las propiedades `yarn.resourcemanager.nodes.include-path` y `yarn.resourcemanager.nodes.exclude-path` al archivo `yarn-site.xml` para indicarle al resourcemanager los ficheros.

A continuación se reinician los demonios con:

```bash
yarn --daemon stop resourcemanager
hdfs --daemon stop namenode
hdfs --daemon start namenode
yarn --daemon start resourcemanager
```

A continuación se añade "datanode5" a la lista de nodos incluidos, se recarga la configuración del resourcemanager con `yarn rmadmin -refreshNodes` y se inicia un el nodo con el comando:

```bash
docker container run -d --name datanode5 --network=hadoop-cluster \
  --hostname datanode5 --cpus=1 --memory=3072m \
  --expose 8000-10000 --expose 50000-50200 datanode-image /inicio.sh
```

En las siguientes capturas se puede ver como el resourcemanager (primera captura) ya tiene constancia del nuevo nodo, pero el namenode todavía no (segunda captura).  
![](img/img014.png)
![](img/img013.png)

Una vez el resourcemanager ya tiene constancia del nuevo nodo ahora se añade al namenode, primero se añade "datanode5" a la lista de nodos incluidos y después se recarga la configuración con `hdfs dfsadmin -refreshNodes`

En las siguientes capturas se puede ver como ya tanto el resourcemanager (primera captura) como el namenode (segunda captura) tienen constancia del nuevo nodo.  
![](img/img016.png)
![](img/img015.png)

Las siguientes dos capturas muestran como también se ve reflejado en la interfaz web que hay un nuevo nodo.  
![](img/img017.png)
![](img/img018.png)

En la siguiente captura se muestra la salida del comando `hdfs balancer`.
No ha movido datos.  
![](img/img019.png)

# Tarea 3: Retirar un DataNode/NodeManager

En primer lugar entro al namenode y me cambio al usuario hdadmin.

```bash
docker container exec -ti namenode /bin/bash
su - hdadmin
```

A continuación añado el datanode4 a la lista de nodos excluidos y recargo la configuración.

```bash
echo "datanode4" > ${HADOOP_HOME}/etc/hadoop/dfs.exclude
echo "datanode4" > ${HADOOP_HOME}/etc/hadoop/yarn.exclude
hdfs dfsadmin -refreshNodes
yarn rmadmin -refreshNodes
```

Una vez recargadas las configuraciones puedo ver en las interfaces web ([http://localhost:8088/cluster/nodes](http://localhost:8088/cluster/nodes) y [http://localhost:9870/dfshealth.html#tab-datanode](http://localhost:9870/dfshealth.html#tab-datanode)) que esta decomisionado el datanode4.  
![](img/img020.png)
![](img/img021.png)

También en los comandos:

```bash
hdfs dfsadmin -report
yarn node -list
```

![](img/img022.png)
![](img/img023.png)

Detengo el contendedor del datanode4 porque ya no será usado.

```bash
docker container stop namenode datanode4

```

Para finalizar pongo en los ficheros `dfs.include` y `yarn.include` solo los nodos que están activos y dejo lso ficheros `dfs.exclude` y `yarn.exclude` vacíos.
Recargo la configuración para que los demonios tengan constancia.

```bash
echo "datanode1
datanode2
datanode3
datanode5" > ${HADOOP_HOME}/etc/hadoop/dfs.include

echo "datanode1
datanode2
datanode3
datanode5" > ${HADOOP_HOME}/etc/hadoop/yarn.include

echo > ${HADOOP_HOME}/etc/hadoop/dfs.exclude
echo > ${HADOOP_HOME}/etc/hadoop/yarn.exclude

hdfs dfsadmin -refreshNodes
yarn rmadmin -refreshNodes
```

# Tarea 4: Rack awareness

En primer lugar entro al namenode y me cambio al usuario hdadmin.

```bash
docker container exec -ti namenode /bin/bash
su - hdadmin
```

Muestro la topologia inicial con el comando `hdfs dfsadmin -printTopology`.  
![](img/img024.png)

Paro el demonio del namenode.

```bash
hdfs --daemon stop namenode
```

Describo la organizacion de los racks y creo el script que hará el mapeo.

```bash
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
```

Doy permisos de ejecución al script.

```bash
chmod +x $HADOOP_HOME/etc/hadoop/topology.script
```

Añado a al fichero `core-site.xml` la propiedad net.topology.script.file.name para indicar donde se encuentra el script que hace el mapeo.

Por último inicio de nuevo el demonio del namenode y muestro la topología.

```bash
hdfs --daemon start namenode
hdfs dfsadmin -printTopology
```

![](img/img025.png)


# Apéndice

Adjunto los ficheros:

- `hadoop_install.sh`: Comandos usados para hacer la instalación del cluster hadoop.
- `t1.sh`: Los comandos usados para hacer la tarea 1.
- `t2.sh`: Los comandos usados para hacer la tarea 2.
- `t3.sh`: Los comandos usados para hacer la tarea 3.
- `t4.sh`: Los comandos usados para hacer la tarea 4.

Los ficheros no estan pensados para ser ejecutados en batch sino copiando y pegando cada uno de los comandos.
