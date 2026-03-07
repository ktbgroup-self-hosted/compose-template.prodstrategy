# Template **Compose** Stack (*Docker Compose*)

## **Compose** with "Environments Strategy"

The "Environments Strategy" just refers to having the ability to deploy stacks intended for "staging" (adding new changes, testing new configurations, anything new, etc.) and "production" (actual usage of container). This approach minimizes downtime while simultaneously allowing for continuous improvements. Containers will now either be ran in a **"production environment"** or **"staging environment"**. All this really means is we are changing the names of resources and swapping out real data for fake data that we can mess up. One example to illustrate this would be that different "environments" will use **completely different volumes** which means your data you actually care about and use is safe. (and you can accidentally drop a database without concern!)

### Starting **Containers**

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

## Files & Structure Explained

### Files & Folders

- `compose.yaml`: Base template for defining a service. Includes any attributes and resources used in both the "staging" and "production" environments (like `image: myimage:latest`).
- `compose.production.yaml`: Configuration of service for actual usage. Looks very similar to `compose.yaml` but only includes attributes that should be overridden **specifically for production** (like `ports:` or app environment variables).
- `compose.production.yaml`: Configuration of service for testing and improvements. Looks very similar to `compose.yaml` but only includes attributes that should be overridden **specifically for staging** (like `ports:` or app environment variables).
- `config/`: Directory storing env files for production and staging environments **ONLY USED FOR INTERPOLATION**.
- `envs/`: Directory storing env files for production and staging environments **ONLY USED FOR DIRECT INJECTION OF VARIABLES INTO CONTAINERS**.
  - Note: Only two files exist in this folder for template purposes, but when creating a stack or project with multiple tightly knit services that need to remain in the same compose file, you **should create more (or different) env files** to only pass in the variables required for the application it is injected into. The naming convention for these files should be `servicename.production.env`.

### Referencing Resources Across Compose Files

If you need to reference a container, network, volume, etc. you will need to use the following format as the typical conventions get adjusted for environments (since there can be no duplicate resource names).

```bash
stackname-environment_resource
```

**stackname-environment:** This is really two separate things but are both set in the `name:` attribute at the top of a compose file. It prefixes all resource names and is manually added to container names. With this strategy, the `name:` attribute can be found in both the `compose.production.yaml` and `compose.staging.yaml` near the top of the file at the root level. The compose file should specify both **stackname** and **environment** in the `name` attribute.

**resource:** this is any given resource created by the target compose stack. Inlcudes things like container, volume, network, etc.

## Linting & Formatting

Yes, linting is a weird thing to hear in relation to docker compose; however, it shouldn't be! We all want files that look the same and work as intended. Linting and formatting is done using a tool called `dclint` which is installed with **npm**.

**Before pushing any changes to a compose file, run the `lint.sh` script in the root of your project.** This will loop through all folders in the current directory, finding compose files and running `dclint` with the `--fix` flag to format and lint them. Below are definitions of linting and formatting related files.

`lint.sh`: Runner for **dclint** (*npm package*) to find all compose files in a directory and run `dclint --fix` to format and lint them.

`.dclintrc`: Definitions for **dclint** to follow. Can be used to ignore certain linting errors, change them to only warnings, or disable them all together.
