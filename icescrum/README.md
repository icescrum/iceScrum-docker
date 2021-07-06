# iceScrum official Docker image

iceScrum is an open-minded and expert agile project management tool based on the Scrum methodology: https://www.icescrum.com/features/.

Tags:
- iceScrum 7.54: `latest`
- iceScrum R6#14.14: `R6` (__deprecated__, documentation: https://github.com/icescrum/iceScrum-docker/blob/R6/icescrum/README.md)

The `R6` version of iceScrum is deprecated, use it only to prepare an existing installation for the migration to iceScrum v7. To migrate, follow this documentation: https://www.icescrum.com/documentation/migration-standalone/.

## iceScrum URL

When iceScrum runs inside a Docker container, it cannot know its external URL. By default it looks like `http://<docker-host>:<external-port>/icescrum`.

If you use a VM (e.g. Docker Machine) the docker host is the VM IP, otherwise it's `localhost` or your machine IP.

### HTTPS through reverse proxy

To set an environment variable when starting a Docker container: add `-e VARIABLE=value` to the `docker run` command.

You need to inform iceScrum that it will be used externally through HTTPS thanks to the ICESCRUM_HTTPS_PROXY environment variable: 
`-e ICESCRUM_HTTPS_PROXY=true`

That is the only thing you have to do on the iceScrum side. However, you need to configure the reverse proxy properly so it works with iceScrum: https://www.icescrum.com/documentation/reverse-proxy/.

### Port

Internally, iceScrum will start on port `8080`. You need to map this internal port to a port of your computer in order to use iceScrum from your computer.

To map a port when starting a Docker container: add `-p external-port:internal-port` to the `docker run` command.

Ensure that `external-port` is not taken by another application on your computer, e.g. `8080` or `8090`.

If you map port `80` of your computer to port `8080` of the container (`-p 80:8080`) then the port can be omitted in the URL. This requires administration permissions.

### Context

If you don't want that the URL ends with `/icescrum`, which is the iceScrum context, then you can change it by setting an environment variable.

The environment variable that defines the context is `ICESCRUM_CONTEXT`, e.g.:
* `-e ICESCRUM_CONTEXT=is`: the URL ends with `/is`
* `-e ICESCRUM_CONTEXT=/`: the URL ends with `/`

## iceScrum persistent files

__No persistent data should be kept inside the container__ and iceScrum needs a place to persist its files. That's why you need to mount a directory of your computer into a directory of the container: `/root`.

To mount a volume when starting a Docker container: add `-v external-directory:internal-directory` to the `docker run` command.

## Start with included H2 database (not safe)

```console
docker run --name icescrum -v /mycomputer/is/home:/root -p 8080:8080 icescrum/icescrum
```

The iceScrum data (config.groovy, logs...) is persisted on your computer into `/mycomputer/is/home` (replace by an absolute or relative path from your computer) and the H2 files are stored under its `h2` directory.

Be careful, the H2 default embedded DBMS __is not reliable for production use__, so we recommend that you rather use an external DBMS such as MySQL.

## Start with MySQL or PostgreSQL with Docker Compose

The connection between iceScrum and a DBMS started in another container requires either `Docker compose` or Docker Networks (see the dedicated section). 

Starting both containers with `Docker compose` ensures that they are both properly configured and started and allows iceScrum to access your MySQL or PostgreSQL container by its name (thanks to an automatic `/etc/hosts` entry).

Use the official MySQL image (`5.7 is recommended as version 8 is not supported yet) or the official PostgreSQL image (`9.6` up to `11` as version 12 is not supported yet).

Here is an example `docker-compose.yml` file that starts iceScrum and MySQL
```yml
version: '3'
services:
  mysql:
    image: mysql:5.7
    volumes:
      - /mycomputer/is/mysql:/var/lib/mysql
    environment:
      - MYSQL_DATABASE=icescrum
      - MYSQL_ROOT_PASSWORD=myPass
    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
  icescrum:
    image: icescrum/icescrum
    volumes:
      - /mycomputer/is/home:/root
    ports:
      - "8080:8080"
    depends_on:
      - mysql
```

## Start with MySQL or PostgreSQL with Docker Networks

Starting both containers on the same network allows iceScrum to access your MySQL or PostgreSQL container by its name (thanks to an automatic `/etc/hosts` entry).

### 1. Create the network

```
docker network create --driver bridge is_net
```

### 2. Start the DB container (pick one!)

#### MySQL

Use the official MySQL image (`5.7` is recommended as version 8 is not supported yet)

Provide a password for the MySQL `root` user and a name for the database (you can use `icescrum`).
```
docker run --name mysql -v /mycomputer/is/mysql:/var/lib/mysql --net=is_net -e MYSQL_DATABASE=icescrum -e MYSQL_ROOT_PASSWORD=myPass -d mysql:5.7 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
```

MySQL data is persisted on your computer into `/mycomputer/is/mysql` (replace by an absolute or relative path from your computer). This may not work on `Docker Machine` due to permission issues unrelated to iceScrum.

#### PostgreSQL

Use the official PostgreSQL image (`9.6` up to `11` as version 12 is not supported yet).

Provide a password for the PostgreSQL `postgre` user and a name for the database (you can use `icescrum`).

```console
docker run --name postgres -v /mycomputer/is/postgres:/var/lib/postgresql/data --net=is_net -e POSTGRES_DB=icescrum -e POSTGRES_PASSWORD=myPass -d postgres:9.6
```

PostgreSQL data is persisted on your computer into `/mycomputer/is/postgres` (replace by an absolute or relative path from your computer). This may not work on `Docker Machine` due to permission issues unrelated to iceScrum.

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

Settings that define where iceScrum stores its files are pre-filled to ensure that everything is persisted in your mounted volume, do not change them unless you know what you do!

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

## Update iceScrum

Follow the upgrade guide: https://www.icescrum.com/documentation/upgrade-guide/.

## Switch database

To migrate from one database to another:

1. Export the projects you want to keep from the running iceScrum application (project > export).
2. Stop the iceScrum container.
3. Change the DB configuration manually in the `config.groovy` file stored on your computer in the directory you defined, see https://www.icescrum.com/documentation/config-groovy/#database.
4. Start the iceScrum container and import your projects (project > import).

## Examples

__Start MySQL and iceScrum on a new `mynet` Docker network on URL http://docker-host:8080/icescrum__
```console
docker network create --driver bridge mynet
docker run --name mysql    -v ~/docker-is/mysql:/var/lib/mysql --net=mynet -e MYSQL_DATABASE=icescrum -e MYSQL_ROOT_PASSWORD=myPass -d mysql:5.7         --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
docker run --name icescrum -v ~/docker-is/home:/root           --net=mynet -p 8080:8080                                                icescrum/icescrum
```

__Start iceScrum with H2 on URL http://docker-host:8090/icescrum__
```console
docker run --name icescrum -v ~/docker-is/home:/root -p 8090:8080 icescrum/icescrum
```

__Start iceScrum with H2 on URL http://docker-host__
```console
docker run --name icescrum -v ~/docker-is/home:/root -p 80:8080 -e ICESCRUM_CONTEXT=/ icescrum/icescrum
```

## Information

The iceScrum Docker image is maintained by the behind iceScrum: __Kagilum__. More information on our website: https://www.icescrum.com/.
