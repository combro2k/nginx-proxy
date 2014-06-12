FROM ubuntu:12.04
MAINTAINER Jason Wilder jwilder@litl.com

# Install Nginx.
RUN apt-get update
RUN apt-get install -y python-software-properties wget
RUN add-apt-repository -y ppa:nginx/stable

RUN apt-get update
RUN apt-get install -y nginx nginx-common nginx-full
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

#fix for long server names
RUN sed -i 's/# server_names_hash_bucket/server_names_hash_bucket/g' /etc/nginx/nginx.conf

RUN mkdir /etc/nginx/ssl
WORKDIR /etc/nginx/ssl 
RUN openssl genrsa  -out server.key 2048
RUN openssl req -new -batch -key server.key -out server.csr
RUN openssl x509 -req -days 10000 -in server.csr -signkey server.key -out server.crt

RUN mkdir /app
WORKDIR /app
ADD . /app

RUN wget -P /usr/local/bin https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego
RUN chmod u+x /usr/local/bin/forego

RUN wget https://github.com/jwilder/docker-gen/releases/download/0.3.0/docker-gen-linux-amd64-0.3.0.tar.gz
RUN tar xvzf docker-gen-linux-amd64-0.3.0.tar.gz

RUN mkdir -p /var/log/supervisor
ADD supervisor.conf /etc/supervisor/conf.d/supervisor.conf

EXPOSE 80 443
ENV DOCKER_HOST unix:///tmp/docker.sock

CMD ["forego", "start", "-r"]
