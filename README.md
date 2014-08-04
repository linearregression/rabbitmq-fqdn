rabbitmq-fqdn
=============

RabbitMQ for clustering using FQDNs

* Sets a consistent erlang cookie to make clustering possible
* Modifies rabbitmq-server and rabbitmqctl scripts to change erlang -sname arg to -name, this enables FQDN support



Example of a 3-node cluster on a single machine for testing purposes, usage of skydns + skydock is assumed for inter-container FQDN DNS resolution


```shell

docker run --name="rmq1" -d --hostname="rmq1.rabbitmq-fqdn.dev.docker" -p :5672:5672 -p :15672:15672 -e "RABBITMQ_NODENAME=rabbit@rmq1.rabbitmq-fqdn.dev.docker" asherwin/rabbitmq-fqdn rabbitmq-server
docker run --name="rmq2" -d --hostname="rmq2.rabbitmq-fqdn.dev.docker" -p :6672:5672 -p :16672:15672 -e "RABBITMQ_NODENAME=rabbit@rmq2.rabbitmq-fqdn.dev.docker" asherwin/rabbitmq-fqdn rabbitmq-server
docker run --name="rmq3" -d --hostname="rmq3.rabbitmq-fqdn.dev.docker" -p :7672:5672 -p :17672:15672 -e "RABBITMQ_NODENAME=rabbit@rmq3.rabbitmq-fqdn.dev.docker" asherwin/rabbitmq-fqdn rabbitmq-server


docker-attach rmq2 rabbitmqctl -n rabbit@rmq2.rabbitmq-fqdn.dev.docker stop_app
docker-attach rmq2 rabbitmqctl -n rabbit@rmq2.rabbitmq-fqdn.dev.docker join_cluster rabbit@rmq1.rabbitmq-fqdn.dev.docker
docker-attach rmq2 rabbitmqctl -n rabbit@rmq2.rabbitmq-fqdn.dev.docker start_app

docker-attach rmq3 rabbitmqctl -n rabbit@rmq3.rabbitmq-fqdn.dev.docker stop_app
docker-attach rmq3 rabbitmqctl -n rabbit@rmq3.rabbitmq-fqdn.dev.docker join_cluster rabbit@rmq1.rabbitmq-fqdn.dev.docker
docker-attach rmq3 rabbitmqctl -n rabbit@rmq3.rabbitmq-fqdn.dev.docker start_app

```

Now have some fun:

```shell

docker kill rmq3
docker restart rmq3
sleep 2
docker kill rmq1 rmq2
docker restart rmq1
docker restart rmq2

```

Verify what happened in one of the server logs... example excerpt of rmq3's /var/log/rabbitmq/rabbit\@rmq3.rabbitmq-fqdn.dev.docker.log

```
=INFO REPORT==== 3-Aug-2014::21:01:38 ===
started TCP Listener on [::]:5672

=INFO REPORT==== 3-Aug-2014::21:01:38 ===
rabbit on node 'rabbit@rmq1.rabbitmq-fqdn.dev.docker' up

=INFO REPORT==== 3-Aug-2014::21:01:38 ===
rabbit on node 'rabbit@rmq2.rabbitmq-fqdn.dev.docker' up

=INFO REPORT==== 3-Aug-2014::21:01:38 ===
Management plugin started. Port: 15672

=INFO REPORT==== 3-Aug-2014::21:01:38 ===
rabbit on node 'rabbit@rmq1.rabbitmq-fqdn.dev.docker' down

=INFO REPORT==== 3-Aug-2014::21:01:38 ===
rabbit on node 'rabbit@rmq2.rabbitmq-fqdn.dev.docker' down

=INFO REPORT==== 3-Aug-2014::21:01:38 ===
Statistics database started.

=INFO REPORT==== 3-Aug-2014::21:01:38 ===
Server startup complete; 6 plugins started.
 * amqp_client
 * mochiweb
 * rabbitmq_management
 * rabbitmq_management_agent
 * rabbitmq_web_dispatch
 * webmachine

=INFO REPORT==== 3-Aug-2014::21:01:40 ===
rabbit on node 'rabbit@rmq1.rabbitmq-fqdn.dev.docker' up

=INFO REPORT==== 3-Aug-2014::21:01:41 ===
rabbit on node 'rabbit@rmq2.rabbitmq-fqdn.dev.docker' up
```
