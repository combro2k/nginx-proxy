FROM ubuntu:14.04
MAINTAINER Jason Wilder jwilder@litl.com

# Install Nginx.
RUN apt-get update
RUN apt-get install -y wget
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62
RUN echo deb http://nginx.org/packages/mainline/ubuntu trusty nginx > /etc/apt/sources.list.d/nginx-stable-trusty.list

RUN apt-get update
RUN apt-get install -y nginx
RUN apt-get upgrade -y

#Add custom nginx.conf file
ADD nginx.conf /etc/nginx/nginx.conf
ADD proxy_params /etc/nginx/proxy_params

RUN mkdir /etc/nginx/ssl
WORKDIR /etc/nginx/ssl

RUN openssl genrsa  -out server.key 2048
RUN openssl req -new -batch -key server.key -out server.csr
RUN openssl x509 -req -days 10000 -in server.csr -signkey server.key -out server.crt
RUN openssl dhparam -out dhparam.pem 4096

RUN mkdir -p /etc/nginx/sites-enabled

RUN mkdir /app
WORKDIR /app
ADD ./app /app

RUN wget -P /usr/local/bin https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego
RUN chmod u+x /usr/local/bin/forego

ADD docker-gen docker-gen

EXPOSE 80 443
ENV DOCKER_HOST unix:///tmp/docker.sock

CMD ["forego", "start", "-r"]
