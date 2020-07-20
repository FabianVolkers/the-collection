# The Collection<!-- omit in TOC -->

A collection of tools and configuration files and steps for the services deployed on my server

## Content<!-- omit in TOC -->
- [Docker Stacks](#docker-stacks)

## Docker Stacks
Most of the services I deploy run inside Docker containers inside a Docker Swarm. The Docker-Compose files for these can be found in [Stacks](./stacks). Here's an overview of the stacks deployed.

### Monitoring
- Grafana
- Prometheus

### Logging
- Elasticsearch
- Kibana
- Filebeat
- Heartbeat
- Logstash

### Nextcloud
- Nextcloud App
- MYSQL DB
- Cron

### Homepage
- Django App
- Postgres DB
- Nginx Webserver

### Wordpress
- Wordpress App
- Wordpress DB

### Webmail

