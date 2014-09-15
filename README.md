Cassandra 2.1.0 as a Docker container. For development use only.

## Quickstart

### Single Node
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
