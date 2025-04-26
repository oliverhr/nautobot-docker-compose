# nautobot-docker-compose

Taked from [Nautobot Docker Compose](https://github.com/nautobot/nautobot-docker-compose) project, so most of the docs and files are taken from there.

I'm using this repo to understand how Nautobot-Docker-Compose build process works, for the moment changes are being only applied to the `base` configuration and **not** to the LDAP part and just for the build process. The main purpose is use migrate from `invoke` to bash replacing it with shell scripts. 

**Read First:**

- https://docs.nautobot.com/projects/core/en/stable/user-guide/administration/guides/docker

## Requirements

- Docker [Desktop | Engine]
  - [Engine](https://docs.docker.com/engine/install/)
  - [Desktop](https://docs.docker.com/desktop/)
- Docker [Compose Plugin](https://docs.docker.com/compose/install/)

**Optional**:

- [Go-Task](https://taskfile.dev/installation/) to run the `Taskfile.yml` included

### Taskfile

A  [Taskfile](https://taskfile.dev/) is included as a way to show how to use the project in a pipeline, this can be replaced easily in your CI/CD configuration file for GitHub or GitLab.

```
~/my-local-pipelines/
└── nautobot-docker-compose/
		├── ...
		├── compose.sh
		└── Taskfile.yml
```
## Configuration

### Custom config.env file

To build the image of Nautobot all the required configuration is available in the file named `config.env` you can override totally or partially the values defined in that file by setting you custom values on a file named `config.dist.env` the values defined there have precedence.

#### Environment Variables

Another way to configure and override the default values set in the configuration `env` files, is to create environment variables prefixed with `NW2C_{PROPERTY_NAME}` thes variables must set before the execution of the `compose.sh` script.

For example if you use the provided Taskfile, to set the Nautobot version to 2.4.7 and call the build process you can run this:

```
NW2C_NAUTOBOT_VERSION='2.4.7' task build
```

To override multiple configuration `env` values you can do shomething like this:

```
export NW2C_IMAGE_NAME='registry.url/namespace/image-name:tag'
export NW2C_PYTHON_SUPPORTED_RANGE='>=3.9.2,<3.13'
export NW2C_NAUTOBOT_VERSION='2.4.7'
export NW2C_PYTHON_VERSION='3.12'

task build
```

### Nautobot configuration

#### Application Environment Variables

Environment files (.env) are the standard way of providing configuration information or secrets in Docker containers. This project includes two example environment files that each serve a specific purpose:

* `settings.env` - The local environment file is intended to store all relevant configurations that are safe to be stored in git. This would typically be things like specifying the database user or whether debug is enabled or not. Do not store secrets, ie passwords or tokens, in this file!
* `credentials.env` - The creds environment file is intended to store all configuration information that you wish to keep out of git.

By default the provided environment files are being used, but is recommended to copy and customize the values as required, also is recommended to use the "composed extension" `*.dist.env` .

```bash
cd environments

cp settings.env	settings.dist.env
chmod 600 settings.dist.env

cp credentials.env	credentials.dist.env
chmod 600 credentials.dist.env
```

### Notes

The pattern `*.dist.env` was added to the `.gitignore` file to let you name these files for your live environments. Avoiding to track .env files is essential to keep passwords and tokens from being leaked accidentally.

### Nautobot python config

>  Add docs about `config/nautobot_config.py` file.

## Go-Task Defined Tasks

The project comes with a Taskfile to help manage the Nautobot environment. The commands are listed below in 2 categories `environment` and `utility`.

Each command can be executed with a simple `task <option>`. Each command also has its own help `task <option> --help`.

### Manage Nautobot environment

#### Images

```
  build            Build the nautobot images.
```

#### Containers

```
  debug            Start Nautobot and its dependencies in debug mode.
  destroy          Destroy all containers and volumes.
  start            Start Nautobot and its dependencies in detached mode.
  stop             Stop Nautobot and its dependencies.
```

#### Extras (not implemented yet)

```
db-export        Export Database data to nautobot_backup.dump.
db-import        Import test data.
```

#### Utility (not implemented yet)

```
  cli              Launch a bash shell inside the running Nautobot container.
  migrate          Run database migrations in Django.
  nbshell          Launch a nbshell session.
```

### Create a Super User Account (not implemented yet)

**Via Environment**

The Docker container has a Docker entry point script that allows you to create a super user by the usage of Environment variables. This can be done by updating the `creds.env` file environment option of `NAUTOBOT_CREATE_SUPERUSER` to `True`. This will then use the information supplied to create the specified superuser.

**Via Container**

After the containers have started run:

```
./compose.sh createsuperuser
```

Or run the task `createsuperuser`

```bash
task createsuperuser
```

Example Prompts:

```bash
Username: administrator
Email address:
Password:
Password (again):
Superuser created successfully.
```

## Additional Documentation

### Plugins

The installation of plugins has a slightly more involved getting-started process. See the [Plugin documentation](docs/plugins.md).

## References

- Docker Hub Network to Code profile
  - https://hub.docker.com/r/networktocode
- Nautobot docker images on docker hub
  - https://hub.docker.com/r/networktocode/nautobot
  - https://hub.docker.com/r/networktocode/nautobot-dev
- Nautobot Development guide:
  - https://docs.nautobot.com/projects/core/en/stable/development/core/getting-started/

- Supported Python versions for the build process are explained on Nautobot repository:

  - Drops support for <= 3.9.1 https://github.com/nautobot/nautobot/pull/7019

  - Drops support for 3.8: https://github.com/nautobot/nautobot/releases/tag/v2.4.0

