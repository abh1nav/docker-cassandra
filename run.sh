#!/bin/bash

# Grab the container IP
ADDR=$(/sbin/ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')
echo "IP Address is: $ADDR"

# Check if a seed was provided
SEED=${SEED:=$ADDR}
echo "Seed is: $SEED"

# Target files
ENV_FILE=/opt/cassandra/conf/cassandra-env.sh
CONF_FILE=/opt/cassandra/conf/cassandra.yaml

# Add heap settings
echo MAX_HEAP_SIZE="4G" >> $ENV_FILE
echo HEAP_NEWSIZE="800M" >> $ENV_FILE

# Add broadcast IPs
echo "listen_address: $ADDR" >> $CONF_FILE
echo "broadcast_rpc_address: $ADDR" >> $CONF_FILE
echo "rpc_address: $ADDR" >> $CONF_FILE

# Add seed info
echo "seed_provider:
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
          - seeds: \"$SEED\"" >> $CONF_FILE

# Start server
cd /opt/cassandra
bin/cassandra -f
