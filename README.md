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

```
git submodule update --init --recursive
```

With all of the relevant code now pulled down, we must install and configure the non-Dockerized dependencies that Web Sight relies upon. Note that the installation process for these dependencies can vary greatly depending on what platform you are using, so I'll leave links here to the technologies and their respective installation instructions:

* [PostgreSQL](https://www.postgresql.org/download/)
* [Elasticsearch 5.*](https://www.elastic.co/guide/en/elasticsearch/reference/current/_installation.html)

Once all of these dependencies have been installed, you will want to:

1. Create a [database user as well as a database within PostgreSQL](https://www.ntchosting.com/encyclopedia/databases/postgresql/create-user/)
2. Give [full permissions for the given database user on the newly-created database](https://www.postgresql.org/docs/9.0/static/user-manag.html)
3. Ensure that the given PostgreSQL user can [access the database server from the IP address(es) where you'll be running Web Sight from](https://www.postgresql.org/docs/9.1/static/auth-pg-hba-conf.html)
4. Create a [user within Elasticsearch](https://www.elastic.co/guide/en/x-pack/current/setting-up-authentication.html)

With all of the Web Sight code pulled down and the software dependencies installed, we can move on to configuring the deployment

## Configuration

Web Sight makes use of a number of third-party services to provide various parts of functionality to application users. In order for Web Sight to be fully functional, you must sign up for these third-party services:

* [Amazon Web Services](https://aws.amazon.com/) (**req'd**) - Usage of S3 (**req'd**) and usage of Amazon Elasticsearch (optional)
* [Farsight DNSDB](https://www.dnsdb.info/) (optional) - Greatly boosts domain name enumeration
* [Stripe](https://stripe.com/docs/api) (**req'd**) - Currently used for payment processing and the API currently requires at least dev credentials for orders to be placed (this will be phased out soon)
* SMTP Mail Server (**req'd**) - Sending emails, can be any SMTP service
* [reCAPTCHA](https://www.google.com/recaptcha/intro/invisible.html) (**req'd**) - Protects against automated attacks, will be phased out soon

Once you have signed up for these services and have the relevant API keys, we can move on to configuring the front- and back-end Web Sight components.