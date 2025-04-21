# LDAP Container Image

The LDAP container image has a different base image than the primary Docker file with Nautobot. The Dockerfile-LDAP has a multi-stage build associated to install the Python components that require GCC. But then the final container being used for running Nautobot does not require GCC.

## Getting Started Using LDAP Container

1. Follow the steps in the README to get your Poetry environment created and confirm you can build containers. For step #7 use `invoke.ldap.yml` instead of `invoke.example.yml`. This will ensure that the LDAP Compose file will be used when building your containers.

2. The LDAP configuration file from is copied from `config/nautobot_config_ldap.py` to `config/nautobot_config.py` as part of the ldap.dockerfile

3. Update settings in the LDAP configuration to match your environment, based on the documentation from [Nautobot docs](https://nautobot.readthedocs.io) the file is located at `config/nautobot_config.py`.

4. Update environment variables in the `local.env` file for the configuration file:

* NAUTOBOT_AUTH_LDAP_SERVER_URI
* NAUTOBOT_AUTH_LDAP_BIND_DN
* NAUTOBOT_AUTH_LDAP_BIND_PASSWORD

5. Build your containers and ensure that the LDAP packages are installed:

```
invoke build --no-cache
```

6. Assuming that your containers are not already running, you'll want to start them:

```
invoke start
```
