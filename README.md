# nautobot-docker-compose

Network to Code has an existing published Nautobot Docker Image on Docker Hub. This project uses Docker Compose. The Docker compose file in this project pulls that Nautobot Docker image using the latest stable Nautobot release along with several other Docker images required for Nautobot to function. See the diagram below. This project is for those looking for a multi-container single-node install for Nautobot often coupled with backup & HA capabilities from their hypervisor manager.

![Container Stack](docs/img/container_stack.png)

By default, this project deploys the Nautobot application, a single worker container, Redis containers, and PostgreSQL. It does not deploy NGINX, SSL, or any Nautobot plugins. However, the project is extensible to allow users to tailor it to their specific requirements. For example, if you need to deploy [SSL](docs/create_ssl_cert.md) or [plugins](docs/plugins.md), see the docs linked. The web server used on the application is [pyuwsgi](https://uwsgi-docs.readthedocs.io/en/latest/).

## Requirements

- Python >= 3.6
- Python modules:
  - invoke
  - toml

```
pip install invoke toml
```

## Configuration

Environment files (.env) are the standard way of providing configuration information or secrets in Docker containers. This project includes two example environment files that each serve a specific purpose:

* `local.example.env` - The local environment file is intended to store all relevant configurations that are safe to be stored in git. This would typically be things like specifying the database user or whether debug is enabled or not. Do not store secrets, ie passwords or tokens, in this file!

* `creds.example.env` - The creds environment file is intended to store all configuration information that you wish to keep out of git. The `creds.env` file is in `.gitignore` and thus will not be pushed to git by default. This is essential to keep passwords and tokens from being leaked accidentally.

To use the provided environment files it's suggested that you copy the file to the same name without the `example` keyword, ie:

```bash
cp environments/local.example.env environments/local.env
cp environments/creds.example.env environments/creds.env

# Make this files available for the current user only.
chmod 0600 environments/local.env environments/creds.env
```

## CLI Helper Commands

The project comes with a CLI helper based on [invoke](http://www.pyinvoke.org/) to help manage the Nautobot environment. The commands are listed below in 2 categories `environment` and `utility`.

Each command can be executed with a simple `invoke <command>`. Each command also has its own help `invoke <command> --help`.

#### Manage Nautobot environment

```bash
  build            Build all docker images.
  debug            Start Nautobot and its dependencies in debug mode.
  destroy          Destroy all containers and volumes.
  start            Start Nautobot and its dependencies in detached mode.
  stop             Stop Nautobot and its dependencies.
  db-export        Export Database data to nautobot_backup.dump.
  db-import        Import test data.
```

#### Utility

```bash
  cli              Launch a bash shell inside the running Nautobot container.
  migrate          Run database migrations in Django.
  nbshell          Launch a nbshell session.
```

## Getting Started

To build a local image of Nautobot you need a file named `invoke.[yml | yaml]`

You can use the `invoke.local.yml` or the `invoke.ldap.yml`:

```bash
# you can create a symlink
ln -s invoke.local.yaml invoke.yaml
# or you can create a copy if you need custom values
cp invoke.example.yml invoke.yml
```

Run `invoke build start` to build the containers and start the environment.

```bash
invoke build start
```

### Create a Super User Account

**Via Environment**

The Docker container has a Docker entry point script that allows you to create a super user by the usage of Environment variables. This can be done by updating the `creds.env` file environment option of `NAUTOBOT_CREATE_SUPERUSER` to `True`. This will then use the information supplied to create the specified superuser.

**Via Container**

After the containers have started:

1. Verify the containers are running:

```bash
docker container ls
```

2. Execute Create Super User Command and follow the prompts

```bash
invoke createsuperuser
```

Example Prompts:

```bash
nautobot@bb29124d7acb:~$ invoke createsuperuser
Username: administrator
Email address:
Password:
Password (again):
Superuser created successfully.
```

### NOTE - MySQL

If you want to use MySQL for the database instead of PostgreSQL use the `invoke.mysql.yml` as invoke file:

```bash
cp invoke.mysql.yml invoke.yml
```

## Additional Documentation

### LDAP

The use of LDAP requires the installation of some additional libraries and some configuration in `nautobot_config.py`. See the [LDAP documentation](docs/ldap.md).

### Plugins

The installation of plugins has a slightly more involved getting-started process. See the [Plugin documentation](docs/plugins.md).

### General Technical information 

If you have questions regarding the technical decisions, you can know more about it on the docs folder on the [technical.md](docs/technical.md) file.

## References

- Docker Hub Network to Code profile
  - https://hub.docker.com/r/networktocode
- Nautobot docker images on docker hub
  - https://hub.docker.com/r/networktocode/nautobot
  - https://hub.docker.com/r/networktocode/nautobot-dev
