# Docker Compose || Template Stack

## Compose with Environments Strategy

The "Environments Strategy" just refers to having the ability to deploy stacks intended for "staging" (adding new changes, testing new configurations, anything new, etc.) and "production" (actual usage of container). This approach minimizes downtime while simultaneously allowing for continuous improvements.

### Starting Containers for Specific Environment

The following command is an example of how you would start the "production environment" version of a stack. All of the following information applies to the "staging environment" as well (just swapping out the phrase "production" for "staging").

```bash
docker compose -f compose.yaml -f compose.production.yaml --env-file ./config/production.env up -d
```

#### Command Breakdown

---

```bash
-f compose.yaml -f compose.production.yaml
```

This specifies `compose.yaml` as the base compose yaml file and `compose.production.yaml` as the overriding compose yaml file. One way to look at it is `compose.yaml` is a template for a given service, and `compose.production.yaml` provides the naming, volumes, ports, networks, etc. to run the service for actual usage. On the other hand `compose.staging.yaml` provides the same naming volumes, etc. but all with bogus values so it's much easier to put up the container and test things without having to worry about anything like secrets, not screwing up data, etc. So, any attributes set in `compose.yaml` take a new value if they are also listed in the `compose.production.yaml`.

---

```bash
--env-file ./config/production.env
```

This specifies an env file to use purely for variable interpolation in any of the `compose*.yaml` (`compose.yaml`, `compose.production.yaml`, `compose.staging.yaml`) files. The reason for specifying it in the command is so all compose files have access to it for interpolation whereas specifying an env file with the `env_file:` attribute in a compose file only allow for injection of the variables into the container, which `./envs/production.env` is used for.

### Referencing Resources Across Compose Files

If you need to reference a container, network, volume, etc. you will need to use the following format as the typical conventions get adjusted for environments (since there can be no duplicate resource names).

```bash
stackname-environment_resource
```

**stackname-environment:** this is really two separate things but are set together. references the name set at the top of a compose file. It prefixes all resource names and is manually added to container names. With this strategy, the `name:` attribute can be found in both the `compose.production.yaml` and `compose.staging.yaml` near the top of the file at the root level. The compose file should specify both **stackname** and **environment** in the `name` attribute.

**resource:** this is any given resource created by the target compose stack. Inlcudes things like container, volume, network, etc.
