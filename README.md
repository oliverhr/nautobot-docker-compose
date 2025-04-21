# nautobot-docker-compose

Taked from [Nautobot Docker Compose](https://github.com/nautobot/nautobot-docker-compose) project, so most of the docs and files are taken from there.

I'm using this repo to understand how Nautobot-Docker-Compose build process works, for the moment changes are being only applied to the `base` configuration and not to the LDAP and just for the build process.

The objective is use [Taskfile](https://taskfile.dev/) which can be replaced easily with a "native" pipeline from GitHub or GitLab.

**Read First:**

- https://docs.nautobot.com/projects/core/en/stable/user-guide/administration/guides/docker

#### Changes

The main differences are:

- Renamed the invoke namespace context/configuration from
  - From `nautobot_docker_compose`
  - To `networktocode`
- Nested some properties used as environment variables for Docker-Compose and Dockerfile
  - `namespace.configuration().networktocode.env`
  - All the properties on `networktocode.env` dictionary must be all caps

## Requirements

- Docker
- Docker Compose plugin
- Python >= 3.6
  - modules: `invoke`

Dependencies for the build are explained on Nautobot repository:
- Drops support for <= 3.9.1 https://github.com/nautobot/nautobot/pull/7019
- Drops support for 3.8: https://github.com/nautobot/nautobot/releases/tag/v2.4.0

```
pip install invoke
```

You can use poetry but is not required on the host

```
poetry install
```

### Taskfile

A `Taskfile` is being added as example is usable, but I place (move) to an upper level from this repository directory.

```
# I end with something like this
~/my-local-pipeles/
├── Taskfile.yml
└── nautobot-docker-compose/
		├── ...
		└── tasks.py
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

### Invoke Environment Variables

Another way to configure or override the configuration for the "invoke namespace" set in the `invoke.ylm` file, is to create environment variables prefixed with `INVOKE_{NAMESPACE}_{PROPERTY_NAME}` in this case the namespace is `NETWORKTOCODE`.

To set the Nautobot version to 2.4.7 and call the build process you can run this:

```
INVOKE_NETWORKTOCODE_NAUTOBOT_VERSION=2.4.7 invoke build
```

Or if what we want is to override multiple configuration `env` values we can do shomething like this:

```
export INVOKE_NETWORKTOCODE_ENV_IMAGE_NAME=resitry.io/namespace/image-name:tag
export INVOKE_NETWORKTOCODE_ENV_PYTHON_SUPPORTED_RANGE='>=3.9.2,<3.13'

export INVOKE_NETWORKTOCODE_NAUTOBOT_VERSION=2.4.7
export INVOKE_NETWORKTOCODE_PYTHON_VERSION=3.12

invoke build
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
- Nautobot Development guide:
  - https://docs.nautobot.com/projects/core/en/stable/development/core/getting-started/
