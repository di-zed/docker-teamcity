# DiZed Docker Compose for working with TeamCity

## Overview of installing Docker Compose

https://docs.docker.com/compose/install/

## Structure

**The most interesting folders:**

1. **./local** Folder for local changes. It can be convenient to use it together with the docker-compose.local.yml file.
2. **./volumes** The folder with Docker Volumes in Linux structure.
   1. **./volumes/data/teamcity_agent/conf/** Configuration files for agents.
   2. **./volumes/data/teamcity_server/datadir/** Server data dir.
   3. **./volumes/opt/buildagent_1/logs/** Build Agent 01 log files.
   4. **./volumes/opt/buildagent_2/logs/** Build Agent 02 log files.
   5. **./volumes/opt/buildagent_3/logs/** Build Agent 03 log files.
   6. **./volumes/opt/teamcity/logs/** TeamCity log files.

## Setup

1. Copy the *./.env.sample* file to the *./.env*. Check it and edit some parameters if needed.
2. Copy the *./volumes/data/teamcity_agent/conf/agent1/buildAgent.properties.sample* file to the *.volumes/data/teamcity_agent/conf/agent1/buildAgent.properties* for configuration Agent 1.
3. Copy the *./volumes/data/teamcity_agent/conf/agent2/buildAgent.properties.sample* file to the *.volumes/data/teamcity_agent/conf/agent2/buildAgent.properties* for configuration Agent 2.
4. Copy the *./volumes/data/teamcity_agent/conf/agent3/buildAgent.properties.sample* file to the *.volumes/data/teamcity_agent/conf/agent3/buildAgent.properties* for configuration Agent 3.
5. **Optional.** Copy the *./docker-compose.local.yml.sample* file to the *./docker-compose.local.yml* and edit it, if you need some changes in the Docker configurations locally.
6. **Optional.** If you want to have local domains for TeamCity, you need to:
   1. Configure proxy. For example, Nginx. You can use *./docker-compose.local.yml* file and *./local* folder for this.
   2. Add the data to your local */etc/hosts* file, like:
    ```text
    127.0.0.1 teamcity.loc
    ```
7. **Optional.** If you get error about permission problems, please do:
   ```shell
   sudo chown -R 1000:1000 ./volumes/data/teamcity_server/datadir
   sudo chown -R 1000:1000 ./volumes/opt/teamcity/logs
   make docker-restart
   ```
8. If everything is done correctly, then after starting Docker, the project will be available via the link http://localhost:8111/. Please proceed and continue with setup.
9. Database connection setup.
   1. Select MySQL database type.
   2. Download JDBC driver for MySQL database type and put it into the *./volumes/data/teamcity_server/datadir/lib/jdbc*.
      1. For example, the file can be downloaded here: https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.30/.
      2. The file name: [mysql-connector-java-8.0.30.jar](https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.30/mysql-connector-java-8.0.30.jar).
   3. Create an empty database.

## Process

**Docker Build**
```shell
docker-compose build
```

**Docker Up (one of them)**
```shell
docker-compose up -d
```
```shell
make docker-local-up
```

**Docker Stop (one of them)**
```shell
docker-compose stop
```
```shell
make docker-local-stop
```

**Docker Restart (one of them)**
```shell
make docker-restart
```
```shell
make docker-local-restart
```

## Containers

### MySQL (8.4.0)

- Host: mysql
- Port: 3306
- User: {see .env file}
- Password: {see .env file}

### TeamCity Server (2024.12.1)

- Host: teamcity
- Port: 8111
- URL: http://localhost:8111/

### TeamCity Agent 1 (2024.12.1)

- Host: teamcity-agent-1
- Config file: *./volumes/data/teamcity_agent/conf/agent1/buildAgent.properties*

### TeamCity Agent 2 (2024.12.1)

- Host: teamcity-agent-2
- Config file: *./volumes/data/teamcity_agent/conf/agent2/buildAgent.properties*

### TeamCity Agent 3 (2024.12.1)

- Host: teamcity-agent-3
- Config file: *./volumes/data/teamcity_agent/conf/agent3/buildAgent.properties*