## Docker Compose

This documentation is now written assuming the latest Docker Compose methodology of using the Docker Compose Plugin instead of the independent docker-compose executable. See the [Docker Compose Plugin installation notes](https://docs.docker.com/compose/install/)

## Why Poetry?

Poetry was chosen to replace both **requirements.txt** and **setup.py**. Poetry uses the `pyproject.toml` file to define package details, main package dependencies, development dependencies, and tool-related configurations. Poetry resolves dependencies and stores the hashes and metadata within the `poetry.lock` file (similar to performing a `pip freeze > requirements.txt`). The `poetry.lock` is what is used to provide consistency for package versions across the project to make sure anyone who is developing on it is using the same Python dependency versions. Poetry also provides virtual environments by simply being in the same directory as the `pyproject.toml` and `poetry.lock` files and executing the `poetry shell` command.

## Why Invoke?

Invoke is a Python replacement for Make. Invoke looks for a `tasks.py` file that contains functions decorated by `@task` that provide the equivalents of **Make targets**.

The reason it was chosen over Makefile was due to our collective familiarity with Python and the ability to organize and re-use Invoke tasks across Cookiecutter templates.  It also makes managing your Nautobot project vastly simpler by issuing simple commands instead of long command strings that can be confusing.

## How to use this repo

This repo is designed to provide a custom build of Nautobot to include a set of plugins which can then be used in a development environment or deployed in production.  Included in this repo is a skeleton Nautobot plugin which is designed only to provide a quick example of how a plugin could be developed.  Plugins should ultimately be built as packages, published to a PyPI style repository and added to the poetry `pyproject.toml` in this repo.  The plugin code should be hosted in their own repositories with their own CI pipelines and not included here.

## Install Docker

Before beginning, install Docker and verify its operation by running `docker run hello-world`. If you encounter any issues connecting to the Docker service, check that your local user account is permitted to run Docker. **Note:** `docker` v1.10.0 or later is required.

## Install Poetry

It is recommended to follow one of the [installation methods detailed in their documentation](https://python-poetry.org/docs/#installation).  It's advised to install poetry as a system-level dependency and not inside a virtual environment.  Once Poetry has been installed you can create the Poetry virtual environment with a few simple commands:

1. `poetry shell`
2. `poetry lock`
3. `poetry install`

The last command, `poetry install`, will install all of the project dependencies for you to manage your Nautobot project.  This includes installing the `invoke` Python project.

