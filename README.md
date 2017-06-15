# Web Sight Docker Deployment

Web Sight is a software platform that enables red and blue teams to automate the information gathering processes required by their day-to-day jobs. At present, Web Sight performs the following activities:

* Domain name enumeration
* DNS record enumeration
* Network scanning (large scale)
* Network service fingerprinting
* SSL support enumeration
* SSL certificate inspection
* Application-layer inspection for supported application protocols (currently only HTTP)

These activities are entirely automated, and require only the following information as scanning "seeds":

* Network ranges
* Domain names

For web applications that are discovered across an organization's domain names and network ranges, the following activities are conducted:

* Virtual host enumeration
* User agent enumeration
* Crawling
* Screen shotting

The goal of automating this information gathering process is to provide users with the situational awareness that proper security strategizing (both offensively and defensively) requires. Simply put, how can you hope to attack and/or defend an organization if you don't have a good understanding of the organization's attack surface at a given point in time? Furthermore, given the nature of enterprise attack surface (constant churn, massive scale), any understanding of attack surface is fleeting, and attack surface must be re-evaluated regularly to maintain situational awareness.

Please note that this documentation is very much a work in progress. If you find any part of it confusing, please feel free to submit a question via GitHub and I will do my best to respond in a timely fashion.

## Introduction

This repository contains the software necessary to get Web Sight's front- and back-end components up and running on top of Docker.

Web Sight is comprised of two main components - the [front-end](https://github.com/lavalamp-/ws-frontend-community) and the [back-end](https://github.com/lavalamp-/ws-backend-community). The front-end is a single page application written using Angular 2 (Typescript) and the back-end is a fairly complicated distributed N-tier system comprised of RabbitMQ, Python (Django Rest Framework, Celery, SQLAlchemy), PostgreSQL, Redis, and Elasticsearch. As may be apparent from this list of dependencies, getting all of the components up and running and working with one another can be a bit of a chore.

Enter [Docker](https://www.docker.com/). If you haven't used Docker before, I highly recommend reading the [getting started Docker documentation](https://docs.docker.com/get-started/). In a nut shell, Docker enables you to quickly deploy applications and all of their dependencies across various environments at ease. This includes deploying N-tier applications that have inter-application dependencies, which makes Docker a perfect fit for Web Sight deployment.

## Dependencies

Dependencies for the [front-](https://github.com/lavalamp-/ws-frontend-community) and [back-end](https://github.com/lavalamp-/ws-backend-community) components can be found in their respective Git repository README files. Getting things deployed through Docker simplifies things a bit, as many of the back-end dependencies are handled within the Docker deployment. All in all, the Docker deployment relies upon the following:

* [Docker](https://www.docker.com/) - All software is deployed within Docker containers and connections between application dependencies is handled by Docker as well
* [Elasticsearch](https://www.elastic.co/) - Data collected by task nodes is largely stored in Elasticsearch to enable rapid querying and insertion at scale as well as to reduce database load
* [PostgreSQL](https://www.postgresql.org/) - Web Sight makes use of PostgreSQL for storage of all database-related data
* [AWS S3](https://aws.amazon.com/s3/) - File storage

## Directory Layout

The contents of the Web Sight Docker project are laid out as follows:

```
/configs/ - Configuration files for the front- and back-end applications
/nginx/ - Files for the Nginx server that is deployed within Docker
/dockerfiles/ - The .dockerfile files for creating the Docker images that the full Docker deployment relies upon
/docker-compose.yaml - The Docker compose file for spinning up the N-tier Web Sight application.
```

## Installation

**Web Sight has been tested and works with both OSX and Ubuntu. The steps here should work on other Linux distributions, but YMMV.**

To get started with the Web Sight Docker deployment, first clone the repository and `cd` into the cloned directory:

```
git clone https://github.com/lavalamp-/ws-docker-community.git
cd ws-docker-community
```

Once the repository is cloned, pull down the front- and back-end repositories that the Docker deployment relies upon by running the following command:

