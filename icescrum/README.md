# iceScrum official Docker image

This is the official iceScrum Docker image, with support for recent Docker versions.

iceScrum is an open-minded and expert agile project management tool based on the Scrum methodology: https://www.icescrum.com/features/.

Tags:
- iceScrum R6#14.11: `latest`

## Environment variables

__Important notice:__ iceScrum must know beforehand the unique external URL that will be used to open it in a browser. By default, this URL is `http://localhost:8080/icescrum`.

If you don't want or cannot expose iceScrum on this URL, our image supports environment variables to define a custom URL.

Pass one or more environment variables to the iceScrum container by adding to the `docker run` command the `-e VARIABLE=value` argument.

#### `ICESCRUM_HTTPS`
If set to `true`, the protocol will be `https` instead of `http` in the URL. Be careful: this is all that this variables does, it does not configure the SSL connection at all.

#### `ICESCRUM_HOST`
__Required if you use docker-machine, e.g. to use Docker on OS X or Windows__, in such case set the IP of your Docker host, provided by `docker-machine ip yourmachine`.

#### `ICESCRUM_PORT`
The iceScrum Docker image will always have iceScrum running on its internal port `8080`, but nothing prevents you from defining a different external port (e.g. by exposing a different port in `docker run` via the `-p` argument).

If you set the port `443` (if `ICESCRUM_HTTPS` is set) or the port `80` then the port will be omitted in the URL.

#### `ICESCRUM_CONTEXT`
It's the name that comes after "/" in the URL. You can either define another one or provide `/` to have an empty context.

## Start with included HSQLDB database (not safe)

Be careful, the HSQLDB default embedded DBMS __is not reliable for production use__, so we recommend that you rather use an external DBMS such as MySQL.

* Start iceScrum with HSQLDB on Linux:
```console
docker run --name icescrum -v /mycomputer/is/home:/root -p 8080:8080 icescrum/icescrum
```
* Start iceScrum with HSQLDB on OS X / Windows / docker-machine:
```console
docker run --name icescrum -e ICESCRUM_HOST=yourDockerHostIP -v /mycomputer/is/home:/root -p 8080:8080 icescrum/icescrum
```

The iceScrum data (config.groovy, logs...) is persisted on your computer into `/mycomputer/is/home` (replace by an absolute or relative path from your computer) and the HSQLDB files are stored under its `hsqldb` directory.

## Start with MySQL or PostgreSQL

This integration makes use of the Docker "networks"" feature, we chose to not use the "link"" feature that seems to be deprecated. Starting both containers on the same network simply allows iceScrum to access your MySQL or PostgreSQL container by its name thanks to an automatic `/etc/hosts` entry.

### 1. Create the network

```
docker network create --driver bridge is_net
```

### 2. Start the DB container (pick one!)

#### MySQL

The iceScrum MySQL image is just a standard MySQL image that creates an database named `icescrum` with the `utf8_general_ci` collation at the first startup.

At first startup you will need to provide a password for the MySQL `root` user.
```
docker run --name mysql -v /mycomputer/is/mysql:/var/lib/mysql --net=is_net -e MYSQL_ROOT_PASSWORD=myPass -d icescrum/mysql
```

MySQL data is persisted on your computer into `/mycomputer/is/mysql` (replace by an absolute or relative path from your computer).

#### PostgreSQL

The iceScrum PostgreSQL image is just a standard PostgreSQL image that creates an `icescrum` database with the `en_US.UTF-8` encoding at the first startup.

At first startup you will need to provide a password for the `postgre` user.

* Start PostgreSQL on Linux, its data is persisted on your computer into `/mycomputer/is/postgres` (replace by an absolute or relative path from your computer):
```console
docker run --name postgres -v /mycomputer/is/postgres:/var/lib/postgresql/data --net=is_net -e POSTGRES_PASSWORD=myPass -d icescrum/postgres
```
* On OS X / Windows / docker-machine __mounting a volume from your OS will not work__, see https://github.com/docker-library/postgres/issues/28, so you will need to keep the PostgreSQL data inside the container. Use the command:
```console
docker run --name postgres --net=is_net -e POSTGRES_PASSWORD=myPass -d icescrum/postgres
```

### 3. Start the iceScrum container

* Start iceScrum with MySQL / PostgreSQL on Linux:
```console
docker run --name icescrum -v /mycomputer/is/home:/root --net=is_net -p 8080:8080 icescrum/icescrum
```
* Start iceScrum with MySQL / PostgreSQL on OS X / Windows / docker-machine:
```console
docker run --name icescrum -e ICESCRUM_HOST=yourDockerHostIP -v /mycomputer/is/home:/root --net=is_net -p 8080:8080 icescrum/icescrum
```

Don't start it in background so you will be able to check that everything goes well in the logs.

iceScrum data (`config.groovy`, logs...) is persisted on your computer into `/mycomputer/is/home` (replace by an absolute or relative path from your computer).

## Startup

The very first line of the iceScrum container output displays the external URL of iceScrum (according to the provided environment variables):
> iceScrum will be available at this URL: http://XXXX

Wait until your see 
> Server startup in XXXX ms

Then iceScrum should be available at the provided URL.

## Setup wizard

If it's the first time you use iceScrum, you will have to configure iceScrum through a user-friendly wizard. Here is the documentation: https://www.icescrum.com/documentation/install-guide/#settings

The setup wizard has two results:
* A `config.groovy` file located under `/mycomputer/is/home/.icescrum`, which you will be able to edit later either manually or through the iceScrum Pro admin interface.
* An admin user for iceScrum in the target database.

Some settings regarding where iceScrum stores its files are prefilled to ensure that everything is persisted in your mounted volume, don't change them unless you know what you do!

The wizard has a "Dabatase" step:

#### HSQLDB

If you want to keep the HSQLDB database then the database configuration is prefilled and you can just click next.

#### MySQL

If you use the MySQL container, choose the MySQL database in the settings and configure it:
* _URL_: replace "localhost" by the name of the MySQL container (in our example: `mysql`)
* _Username_: `root`
* _Password_: the one defined when starting the MySQL container (in our example: `myPass`)

When clicking on next, a database connection is tried and if you get no error then it is successful.

You will be told to restart the container at the very end of the setup so iceScrum can start on your custom DB:
```console
docker restart icescrum
```

#### PostgreSQL

If you use the PostgreSQL container, choose the PostgreSQL database in the settings and configure it:
* _URL_: replace "localhost" by the name of the PostgreSQL container (in our example: `postgres`)
* _Username_: `postgres`
* _Password_: the one defined when starting the PostgreSQL container (in our example: `myPass`)

When clicking on next, a database connection is tried and if you get no error then it is successful.

You will be told to restart the container at the very end of the setup so iceScrum can start on your custom DB:
```console
docker restart icescrum
```

## Switch database

To migrate from one database to another:

1. Export the projects you want to keep from the running iceScrum application (project > export).

2. Stop the iceScrum container.

3. Change the DB configuration manually in the `config.groovy` file stored on your computer in the directory you defined, see https://www.icescrum.com/documentation/config-groovy-file/#database. If you come from HSQLDB, you can alternatively delete the `hsqldb` directory so the setup wizard will show up again on next startup.

4. Start the iceScrum container and import your projects (project > import).

## Docker Compose

Here is an example docker-compose.yml file that starts iceScrum and MySQL
```yml
version: '2'
services:
  mysql:
    image: icescrum/mysql
    volumes:
      - /mycomputer/is/mysql:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=myPass
  icescrum:
    image: icescrum/icescrum
    ports:
      - "8080:8080"
    volumes:
      - /mycomputer/is/home:/root
    links:
      - mysql
```

## Examples

__Start MySQL and iceScrum on a new `mynet` Docker network on Linux__
```console
docker network create --driver bridge mynet
docker run --name mysql -v ~/docker-is/mysql:/var/lib/mysql --net=mynet -e MYSQL_ROOT_PASSWORD=secretPass -d icescrum/mysql
docker run --name icescrum -v ~/docker-is/home:/root -p 8080:8080 --net=mynet icescrum/icescrum
```

__Start iceScrum with HSLQDB on OS X on port 8090 by retrieving the docker-machine default VM IP automatically__
```console
docker run --name icescrum                               \
           -e ICESCRUM_HOST=$(docker-machine ip default) \
           -e ICESCRUM_PORT=8090                         \
           -v ~/docker-is/home:/root                     \
           -p 8090:8080                                  \
           icescrum/icescrum
```

__Start iceScrum with HSLQDB on URL http://scrum.mydomain.com__
```console
docker run --name icescrum                     \
           -e ICESCRUM_HOST=scrum.mydomain.com \
           -e ICESCRUM_CONTEXT=/               \
           -e ICESCRUM_PORT=80                 \
           -v ~/docker-is/home:/root           \
           -p 80:8080                          \
           icescrum/icescrum
```

## Information

The iceScrum Docker image is maintained by the company who develops iceScrum: __Kagilum__. More information on our website: https://www.icescrum.com/.

We would like to thank Caner Candan who was the first to develop and maintain an iceScrum docker image!
