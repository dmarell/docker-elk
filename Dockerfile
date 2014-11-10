FROM dockerfile/java:oracle-java8
MAINTAINER Daniel Marell <daniel@marell.se>

#Prevent daemon start during install
RUN	echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && \
    chmod +x /usr/sbin/policy-rc.d

RUN DEBIAN_FRONTEND=noninteractive apt-get update

#Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && \
	mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y maven ntp net-tools inetutils-ping curl git telnet

#ElasticSearch
RUN wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.0.tar.gz && \
    tar xf elasticsearch-*.tar.gz && \
    rm elasticsearch-*.tar.gz && \
    mv elasticsearch-* elasticsearch && \
    elasticsearch/bin/plugin -install mobz/elasticsearch-head

#Kibana
RUN wget https://download.elasticsearch.org/kibana/kibana/kibana-3.1.1.tar.gz && \
    tar xf kibana-*.tar.gz && \
    rm kibana-*.tar.gz && \
    mv kibana-* kibana

#NGINX
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y  nginx

#Logstash
RUN wget https://download.elasticsearch.org/logstash/logstash/logstash-1.4.0.tar.gz && \
	tar xf logstash-*.tar.gz && \
    rm logstash-*.tar.gz && \
    mv logstash-* logstash
    
#Configuration
ADD ./ /docker-elk
RUN cd /docker-elk && \
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.saved && \
    cp nginx.conf /etc/nginx/nginx.conf

#80=ngnx, 9200=elasticsearch, 42000=logstash
EXPOSE 80 9200 42000
