FROM dockerfile/java:oracle-java7

MAINTAINER Abhinav Ajgaonkar <abhinav316@gmail.com>

RUN \
	mkdir /opt/cassandra; \
	wget -O - http://apache.mirror.gtcomm.net/cassandra/2.1.0/apache-cassandra-2.1.0-bin.tar.gz \
	| tar xzf - --strip-components=1 -C "/opt/cassandra";

ADD	.	/src

RUN	\
	cp /src/cassandra.yaml /opt/cassandra/conf/

EXPOSE 7199 7000 7001 9160 9042

WORKDIR /src

CMD	["./run.sh"]
