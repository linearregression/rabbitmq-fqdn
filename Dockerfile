#
# RabbitMQ ready for clustering using FQDN's
# version: 1.0.0
#

FROM ubuntu:14.04
MAINTAINER Alex Sherwin <alex.sherwin@gmail.com>

# https://github.com/docker/docker/issues/6345
RUN alias adduser='useradd'
RUN ln -s -f /bin/true /usr/bin/chfn

RUN apt-get update
RUN alias adduser='useradd' && DEBIAN_FRONTEND=noninteractive apt-get install -y rabbitmq-server
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN /usr/sbin/rabbitmq-plugins enable rabbitmq_management

RUN echo "rmqcookie" > /var/lib/rabbitmq/.erlang.cookie && chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie && chmod 0600 /var/lib/rabbitmq/.erlang.cookie

# change erlang arg -sname to -name, which switches from short names to FQDN for erlang networking
RUN sed -ri 's/-sname \$\{RABBIT/-name \$\{RABBIT/' rabbitmq-server
RUN sed -ri 's/-sname/-name/' rabbitmqctl

CMD ["/usr/sbin/rabbitmq-server"]

EXPOSE 15672
EXPOSE 5672
