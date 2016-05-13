FROM abh1nav/java7
MAINTAINER James Quacinella <james.quacinella@gmail.com>

# Download and extract Cassandra
RUN \
  mkdir /opt/cassandra; \
  wget -O - http://www.us.apache.org/dist/cassandra/2.2.6/apache-cassandra-2.2.6-bin.tar.gz \
  | tar xzf - --strip-components=1 -C "/opt/cassandra";

# Download and extract DataStax OpsCenter Agent
RUN \
  mkdir /opt/agent; \
  wget -O - http://downloads.datastax.com/community/datastax-agent-5.2.4.tar.gz \
  | tar xzf - --strip-components=1 -C "/opt/agent";

ADD	. /src

# Copy over daemons
RUN	\
	cp /src/cassandra.yaml /opt/cassandra/conf/; \
    mkdir -p /etc/service/cassandra; \
    cp /src/cassandra-run /etc/service/cassandra/run; \
    mkdir -p /etc/service/agent; \
    cp /src/agent-run /etc/service/agent/run

# Basic utils: commented out but some might find these tools useful for debugging
# RUN apt-get update && apt-get install -y dnsutils telnet curl lsof wget vim tcpdump --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Need python for cql
RUN apt-get update && apt-get install -y python --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Expose ports
EXPOSE 7199 7000 7001 9160 9042

WORKDIR /opt/cassandra

CMD ["/sbin/my_init"]

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
