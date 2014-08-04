rabbitmq-fqdn
=============

RabbitMQ dockerfile

* Sets a consistent erlang cookie to make clustering possible
* Modifies rabbitmq-server and rabbitmqctl scripts to change erlange -sname arg to -name, this enables FQDN support

Example of a 3-node cluster on a single machine for testing purposes:


```shell

# dns server
docker run -d -p 172.17.42.1:53:53/udp --name skydns crosbymichael/skydns -nameserver 8.8.8.8:53 -domain docker
# dns docker integration
docker run -d -v /var/run/docker.sock:/docker.sock --name skydock crosbymichael/skydock -ttl 30 -environment dev -s /docker.sock -domain docker -name skydns


docker run --name="rmq1" -d --hostname="rmq1.rabbitmq-fqdn.dev.docker" -p :5672:5672 -p :15672:15672 -e "RABBITMQ_NODENAME=rabbit@rmq1.rabbitmq-fqdn.dev.docker" asherwin/rabbitmq-fqdn rabbitmq-server
docker run --name="rmq2" -d --hostname="rmq2.rabbitmq-fqdn.dev.docker" -p :6672:5672 -p :16672:15672 -e "RABBITMQ_NODENAME=rabbit@rmq2.rabbitmq-fqdn.dev.docker" asherwin/rabbitmq-fqdn rabbitmq-server


docker-attach rmq2 rabbitmqctl stop_app
docker-attach rmq2 rabbitmqctl join_cluster rabbit@rmq1
docker-attach rmq2 rabbitmqctl start_app

docker-attach rmq3 rabbitmqctl stop_app
docker-attach rmq3 rabbitmqctl join_cluster rabbit@rmq1
docker-attach rmq3 rabbitmqctl start_app

```

Note that the limitation here is on docker's one-way container linking, so if you kill rmq1 and restart, it will not be able to rejoin the cluster.  However, testing killing rmq3 will work fine.
