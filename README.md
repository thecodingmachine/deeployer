# Deeployer

## WORK IN PROGRESS

Deeployer's goal is to allow you to describe an environment (be it a dev or a prod environment) in a simple JSON file.

You write a single "deeployer.json" file and you can deploy easily to a Kubernetes cluster, or to a single server with docker-compose.

Deeployer's goal is not to be 100% flexible (you have Kubernetes for that), but rather to ease the deployment process for developers
that do not necessarily master the intricacies of Kubernetes.

It aims to automate a number of processes, including easy backup setup, easy reverse proxy declaration, etc...

## The Deeployer config file

The Deeployer config file contains the list of containers that makes your environment:

**deeployer.json**
```json
{
  "$schema": "https://raw.githubusercontent.com/thecodingmachine/deeployer/master/deeployer.schema.json",
  "version": "1.0",
  "containers": {
     "mysql": {
       "image": "mysql:8.0",
       "ports": [3306],
       "env": {
         "MYSQL_ROOT_PASSWORD": "secret"
       }
     },
    "phpmyadmin": {
      "image": "phpmyadmin/phpmyadmin:5.0",
      "host": {
        "url": "phpmyadmin.myapp.localhost",
        "containerPort": 80
      },
      "env": {
        "PMA_HOST": "mysql",
        "MYSQL_ROOT_PASSWORD": "secret"
      }
    }
  }
}
```

TODO: add volumes when ready

Let's have a closer look at this file.

The first line is optional:

```
  "$schema": "https://raw.githubusercontent.com/thecodingmachine/deeployer/master/deeployer.schema.json",
```
(TODO: migrate the URL to a static website)

It declares the JsonSchema. We highly recommend to keep this line. Indeed, if you are using an IDE like Visual Studio
Code or a JetBrain's IDE, you will get auto-completion and validation of the structure of the file right in your IDE!

Then, the "containers" section contains the list of containers for your environment.
In the example above, we declare 2 containers: "mysql" and "phpmyadmin".
Just like in "docker-compose", the name of the container is also an internal DNS record. So from any container of your
environment, the "mysql" container is reachable at the "mysql" domain name. 

For each container, you need to pass:

- "image": the Docker image for the container
- "ports": a list of ports this image requires. Warning! Unlike in `docker-compose`, this is not a list of ports that
  will be shared with the host. This is simply a list of ports this image opens. This is particularly important if you
  do deployments in Kubernetes (each port will be turned into a K8S service).

You can pass environment variables using the "env" key:

```json
"env": {
 "MYSQL_ROOT_PASSWORD": "secret"
}
```

We will see later how to manage those secrets without storing them in full text. (TODO)
 

## Using Jsonnet

JSON is not the only format supported for the "Deeployer" config file. You can also write the file in [Jsonnet](https://jsonnet.org/learning/tutorial.html).

Jsonnet? This is a very powerful data templating language for JSON.

By convention, you should name your Deeployer file `deeployer.libsonnet`. (TODO: switch to `deeployer.jsonnnet`)

Here is a sample file:

**deeployer.libsonnet**
```jsonnnet
{
  local mySqlPassword = "secret",
  local baseUrl = "myapp.localhost",
  "$schema": "https://raw.githubusercontent.com/thecodingmachine/deeployer/master/deeployer.schema.json",
  "version": "1.0",
  "containers": {
     "mysql": {
       "image": "mysql:8.0",
       "ports": [3306],
       "env": {
         "MYSQL_ROOT_PASSWORD": mySqlPassword
       }
     },
    "phpmyadmin": {
      "image": "phpmyadmin/phpmyadmin:5.0",
      "host": {
         "url": "phpmyadmin."+baseUrl
         "containerPort": 80
      },
      "env": {
        "PMA_HOST": "mysql",
        "MYSQL_ROOT_PASSWORD": mySqlPassword
      }
    }
  }
}
```

In the example above, we declare 2 variables and use these variables in the config file. See how the `mySqlPassword`
variable is used twice? Jsonnet allows us to avoid duplicating configuration code in all containers.

But there is even better! Let's assume you have a staging and a production environment. Maybe you want PhpMyAdmin on the
staging environment (for testing purpose) but not on the production environment. Using Jsonnet, we can do this easily
using 2 files:

**deeployer.libsonnet**
```jsonnnet
{
  local mySqlPassword = "secret",
  "$schema": "https://raw.githubusercontent.com/thecodingmachine/deeployer/master/deeployer.schema.json",
  "version": "1.0",
  "containers": {
     "mysql": {
       "image": "mysql:8.0",
       "ports": [3306],
       "env": {
         "MYSQL_ROOT_PASSWORD": mySqlPassword
       }
     }
  }
}
```

**deeployer-dev.libsonnet**
```jsonnnet
local prod = import "deeployer.libsonnet";
local baseUrl = "myapp.localhost";
prod + {
  "containers"+: {
    "phpmyadmin": {
      "image": "phpmyadmin/phpmyadmin:5.0",
      "host": {
        "url": "phpmyadmin."+baseUrl,
        "containerPort": 80
      },
      "env": {
        "PMA_HOST": "mysql",
        "MYSQL_ROOT_PASSWORD": prod.containers.mysql.env.MYSQL_ROOT_PASSWORD
      }
    }
  }
}
```

TODO: test this.


## Referencing environment variables in the Deeployer config file

When doing continuous deployment, it is common to put environment dependant variables and secrets in environment
variables. Deeployer can access environment variables using the Jsonnet "env" external variable:

**deeployer.libsonnet**
```jsonnnet
local env = std.extVar("env");
{
  local mySqlPassword = "secret",
  "version": "1.0",
  "containers": {
     "mysql": {
       "image": "mysql:8.0",
       "ports": [3306],
       "env": {
         "MYSQL_ROOT_PASSWORD": env.MYSQL_PASSWORD
       }
     }
  }
}
```

The first line is putting all environments variables in the `env` local variable:

```jsonnet
local env = std.extVar("env");
```

Then, you can access all environment variables from the machine running Deeployer using `env.ENV_VARIABLE_NAME`.

Beware! If the environment variable is not set, Jsonnet will throw an error!

### Enabling HTTPS

Deeployer offers HTTPS support out of the box using Let's encrypt.

**deeployer.json**
```json
{
  "
  ": "1.0",
  "$schema": "https://raw.githubusercontent.com/thecodingmachine/deeployer/master/deeployer.schema.json",
  "containers": {
    "phpmyadmin": {
      "image": "phpmyadmin/phpmyadmin:5.0",
      "host": {
        "url": "phpmyadmin.myapp.localhost",
        "containerPort": 80,
        "https": "enable"
      },
      "env": {
        "PMA_HOST": "mysql"
        "MYSQL_ROOT_PASSWORD": "secret"
      }
    }
  },
  "config": {
    "https": {
      "mail": "mymail@example.com"
    }
  }
}
```

In order to automatically get a certificate for your HTTPS website, you need to:

- Add `"https": "enable"` in your `host` section
- At the bottom of the `deeployer.json` file, add a "config.https.mail" entry specifying a mail address. This mail address
  will be used to warn you, should something goes wrong with the certificate (for instance if the certificate is going
  to expire soon)

Please note that if you are using Kubernetes, you will need in addition to install CertManager in your cluster.
[See the relevant Kubernetes documentation below](#configuring-your-kubernetes-cluster-to-support-https) 

### Customizing Kubernetes resources

Deeployer's goal is to allow you to describe a complete environment in a simple JSON file. It simplifies a lot the 
configuration by making a set of common assumptions on your configuration. Of course, the JSON config file does not
let you express everything you can in a raw Kubernetes environment. This is by design.

However, there are times when you might need a very specific K8S feature. In this case, you can use JSONNET functions
to dynamically alter the generated K8S configuration files.

To do this, you will need to use a `deeployer.libsonnet` configuration file instead of a `deeployer.json` configuration
file.

You can then use the hidden `config.k8sextension` field to alter the generated configuration.
In the example below, we are adding 2 annotations to the container of the deployment:

```libsonnet
{
  "version": "1.0",
  "containers": {
    "phpmyadmin": {
      "image": "phpmyadmin",
      "ports": [
        80
      ],
      "host": {
        "url": "myhost.com"
      }
    }
  },
  "config": {
    k8sextension(k8sConf)::
      k8sConf + {
        phpmyadmin+: {
          deployment+: {
            spec+: {
              template+: {
                metadata+: {
                  annotations+: {
                    "prometheus.io/port": "8080",
                    "prometheus.io/scrape": "true"
                  }
                }
              }
            }
          }
        }
      }
  }
}
``` 

What is going on here? We are describing in the config a `k8sextension` function.
This JSONNET function is passed a JSON object representing the complete list of all the Kubernetes resources.
Using JSONNET, we extend that list to add annotations in one given container.

Good to know:

Resources stored in the JSON config object passed to `k8sextension` is on two levels. 

- The first level is the name of the container (`phpmyadmin` in the example above)
- The second level is the name of the resource type we want to target (here, a `deployment`)

## Usage

### Deploying using Kubernetes

View the list of Kubernetes resources that will be generated using `deeployer-k8s show`

```console 
$ deeployer-k8s show
```

By default, Deeployer will look for a `deeployer.libsonnet` or a `deeployer.json` file in the current working directory.

You can specify an alternative name in the command:

```console 
$ deeployer-k8s show deeployer-dev.jsonnet
```

The "show" command is only used for debugging. In order to make an actual deployment, use the "apply" command:

```console 
$ deeployer-k8s apply --namespace=target-namespace
```

Important: if you are using Deeployer locally, Deeployer will not use your Kubectl config by default. You need to pass
the Kubectl configuration as an environment variable.

Finally, you can delete a complete namespace using:

```console 
$ deeployer-k8s delete --namespace=target-namespace
```

This is equivalent to using:

```console 
$ kubectl delete namespace target-namespace
```

#### Connecting to a "standard" environment

If a "kubeconfig" file is enough to connect to your environement, you can connect to your cluster
by setting the `KUBE_CONFIG_FILE` environment variable.

- `KUBE_CONFIG_FILE` should contain the content of the *kubeconfig* file.

#### Connecting to a GCloud environment

You can connect to a GKE cluster by setting these environment variables:

- `GCLOUD_SERVICE_KEY`
- `GCLOUD_PROJECT`
- `GCLOUD_ZONE`
- `GKE_CLUSTER`

#### Configuring your Kubernetes cluster to support HTTPS

In order to have HTTPS support in Kubernetes, you need to install [Cert Manager](https://cert-manager.io/) in your Kubernetes cluster.
Cert Manager is a certificate management tool that acts **cluster-wide**. Deeployer configures Cert Manager to generate
certificates using [Let's encrypt](https://letsencrypt.org/).

You can install Cert Manager using [their installation documentation](https://cert-manager.io/docs/installation/kubernetes/).
You do not need to create a "cluster issuer" as Deeployer will come with its own issuer.

You need to install Cert Manager v0.11+.

### Deploying using docker-compose

TODO


## Installing locally

In order to use Deeployer locally, you need to install:

- [Docker](https://docs.docker.com/get-docker/)
- [jq](https://stedolan.github.io/jq/download/)

Deeployer can be run via Docker. Installation is as easy as adding a few aliases to your `~/.bashrc` (if you are using Bash)

`~/.bashrc`
```console
alias deeployer-k8s="docker run --rm -it -e \"JSON_ENV=\$(jq -n env)\" -v $(pwd):/var/app thecodingmachine/deeployer:latest deeployer-k8s"
alias deeployer-self-update="docker pull thecodingmachine/deeployer:latest"
```

Deeployer is under heavy development. Do not forget to update the Docker image regularly:

```console
$ deeployer-self-update
```

## Usage in Gitlab CI

TODO

## Usage in Github actions

Deeployer comes with a Github action.

```deploy_workflow.yaml
name: Deploy Docker image

on:
  - push

jobs:
  deeploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Deploy
        uses: thecodingmachine/deeployer@master
        env:
          KUBE_CONFIG_FILE: ${{ secrets.KUBE_CONFIG_FILE }}
        with:
          namespace: target-namespace
```

You will need to put the content of your Kubernetes configuration file in the `KUBE_CONFIG_FILE` secret on Github.

### Deploying using the Github action in a Google cloud Kubernetes cluster

If you are connecting to a Google Cloud cluster, instead of passing a `KUBE_CONFIG_FILE`, you will need to pass
this set of environment variables:

- `GCLOUD_SERVICE_KEY`
- `GCLOUD_PROJECT`
- `GCLOUD_ZONE`
- `GKE_CLUSTER`

## Contributing

Download and install the Jsonnet Bundler: https://github.com/jsonnet-bundler/jsonnet-bundler/releases

Install the dependencies:

```bash
$ jb install
```

Download and install Tanka: https://github.com/grafana/tanka/releases

Download and install Kubeval: https://kubeval.instrumenta.dev/installation/

Download and install AJV:

```bash
$ sudo npm install -g ajv-cli
```

Download and install Jsonlint:

```bash
$ sudo npm install -g jsonlint
```

Before submitting a PR:

- run the tests:
  ```console
  cd tests/
  ./run_tests.sh
  ```
- run the linter:
  ```console
  ./lint.sh
  ```
