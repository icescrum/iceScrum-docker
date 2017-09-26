# iceScrum official Docker image

iceScrum is an open-minded and expert agile project management tool based on the Scrum methodology: https://www.icescrum.com/features/.

__The R6 version of iceScrum will be deprecated soon. Use the R6 image only to upgrade an existing installation and prepare it for the migration to iceScrum v7.__ To migrate, follow this documentation: https://www.icescrum.com/documentation/migration-standalone/.

Tags:
- iceScrum 7.2.1: `latest`
- iceScrum R6#14.14: `R6` (documentation: https://github.com/icescrum/iceScrum-docker/blob/R6/icescrum/README.md)

## iceScrum URL

When iceScrum runs inside a Docker container, it cannot know its external URL. By default it looks like `http://<docker-host>:<external-port>/icescrum`.

If you use a VM (e.g. Docker Machine) the docker host is the VM IP, otherwise it's `localhost` or your machine IP.

There is no `https` support for the moment for this Docker image.

### Port

Internally, iceScrum will start on port `8080`. You need to map this internal port to a port of your computer in order to use iceScrum from your computer.

As a reminder, here is how you map a port when starting a container: add `-p external-port:internal-port` to the docker run` command.

Ensure that `external-port` is available on your computer, e.g. `8080` or `8090`.

If you map port `80` of your computer to port `8080` of the container (`-p 80:8080`) then the port can be omitted in the URL. This requires administration permissions.

### Context

If you don't want that the URL ends with `/icescrum`, which is the iceScrum context, then you can change it by setting an environment variable.

As a reminder, here is how you set an environment variable when starting a container: add `-e VARIABLE=value` to the `docker run` command.

The environment variable that defines the context is `ICESCRUM_CONTEXT`, e.g.:
* `-e ICESCRUM_CONTEXT=is`: the URL ends with `/is`
* `-e ICESCRUM_CONTEXT=/`: the URL ends with `/`

## iceScrum persistent files

No persistent data should be kept inside the container and iceScrum needs a place to persist its files. That's why you need to mount a directory of your computer into a directory of the container: `/root`.

As a reminder, here is how you mount a volume when starting a container: add `-v external-directory:internal-directory` to the `docker run` command.

## Start with included H2 database (not safe)

```console
docker run --name icescrum -v /mycomputer/is/home:/root -p 8080:8080 icescrum/icescrum
```

The iceScrum data (config.groovy, logs...) is persisted on your computer into `/mycomputer/is/home` (replace by an absolute or relative path from your computer) and the H2 files are stored under its `h2` directory.

Be careful, the H2 default embedded DBMS __is not reliable for production use__, so we recommend that you rather use an external DBMS such as MySQL.

## Start with MySQL or PostgreSQL

This connection requires using Docker networks. Starting both containers on the same network allows iceScrum to access your MySQL or PostgreSQL container by its name (thanks to an automatic `/etc/hosts` entry).

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

MySQL data is persisted on your computer into `/mycomputer/is/mysql` (replace by an absolute or relative path from your computer). This may not work properly on `Docker Machine` due to permission issues unrelated to iceScrum.

#### PostgreSQL

The iceScrum PostgreSQL image is just a standard PostgreSQL image that creates an `icescrum` database with the `en_US.UTF-8` encoding at the first startup.

At first startup you will need to provide a password for the `postgre` user.

```console
docker run --name postgres -v /mycomputer/is/postgres:/var/lib/postgresql/data --net=is_net -e POSTGRES_PASSWORD=myPass -d icescrum/postgres
```

PostgreSQL data is persisted on your computer into `/mycomputer/is/postgres` (replace by an absolute or relative path from your computer). This may not work properly on `Docker Machine` due to permission issues unrelated to iceScrum.

### 3. Start the iceScrum container

```console
docker run --name icescrum -v /mycomputer/is/home:/root --net=is_net -p 8080:8080 icescrum/icescrum
```

iceScrum data (`config.groovy`, logs...) is persisted on your computer into `/mycomputer/is/home` (replace by an absolute or relative path from your computer).

## Setup wizard

If it's the first time you use iceScrum, you will have to configure iceScrum through a user-friendly wizard. Here is the documentation: https://www.icescrum.com/documentation/how-to-install-icescrum/#settings

The setup wizard has two results:
* A `config.groovy` file located under `/mycomputer/is/home/.icescrum`, which you will be able to edit later either manually or through the iceScrum Pro admin interface.
* An admin user for iceScrum in the target database.

Settings that define where iceScrum stores its files are prefilled to ensure that everything is persisted in your mounted volume, don't change them unless you know what you do!

The wizard has a "Dabatase" step:

#### H2

If you want to keep the H2 database then the database configuration is prefilled and you can just click next.

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
3. Change the DB configuration manually in the `config.groovy` file stored on your computer in the directory you defined, see https://www.icescrum.com/documentation/config-groovy/#database.
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

__Start MySQL and iceScrum on a new `mynet` Docker network on URL http://<docker-host>:8080/icescrum__
```console
docker network create --driver bridge mynet
docker run --name mysql    -v ~/docker-is/mysql:/var/lib/mysql    --net=mynet -e MYSQL_ROOT_PASSWORD=secretPass -d icescrum/mysql
docker run --name icescrum -v ~/docker-is/home:/root              --net=mynet -p 8080:8080                         icescrum/icescrum
```

__Start iceScrum with H2 on URL http://<docker-host>:8090/icescrum__
```console
docker run --name icescrum -v ~/docker-is/home:/root -p 8090:8080 icescrum/icescrum
```

__Start iceScrum with H2 on URL http://<docker-host>__
```console
docker run --name icescrum -v ~/docker-is/home:/root -p 80:8080 -e ICESCRUM_CONTEXT=/ icescrum/icescrum
```

## Information

The iceScrum Docker image is maintained by the behind iceScrum: __Kagilum__. More information on our website: https://www.icescrum.com/.
