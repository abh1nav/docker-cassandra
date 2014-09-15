Cassandra 2.1.0 as a Docker container. For development use only.  

## Quickstart

### TL;DR

Paste this into your terminal to start a 5 node cluster:  

```
bash <(curl -sL http://bit.ly/docker-cassandra)
```

OR, if you don't trust the one-liner, here are its contents:
  
```
docker pull abh1nav/cassandra:latest
docker run -d --name cass1 abh1nav/cassandra:latest
SEED_IP=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' cass1)
for name in cass{2..5}; do
  echo "Starting node $name"
  docker run -d --name $name -e SEED=$SEED_IP abh1nav/cassandra:latest
  echo "Waiting for $name to be up"
  sleep 10
done
echo "Run \"nodetool --host $SEED_IP status\" to check the status of your cluster"

```

### Single Node
Pull the image and launch the node.  
  
```
docker pull abh1nav/cassandra:latest

docker run -d --name cass1 abh1nav/cassandra:latest
```
  
Grab the node's IP using:  
  
```
docker inspect -f '{{ .NetworkSettings.IPAddress }}' cass1
```
  
Connect to it using CQLSH:  
  
```
cqlsh <container ip>
```
  
### Multiple Nodes
  
Follow the single node setup to get the first node running and keep track of its IP. Then:  
  
```
SEED_IP="172.17.0.27" # This is cass1's IP
for name in cass{2..5}; do
  echo "Starting node $name"
  docker run -d --name $name -e SEED=$SEED_IP abh1nav/cassandra:latest
  sleep 10
done
```
  
Once all the nodes are up, check cluster status using:  
  
```
nodetool --host <ip of node> status
```
