# Deeployer

## WORK IN PROGRESS

Deeployer's goal is to allow you to describe an environment (be it a dev or a prod environment) in a simple JSON file.

You write a single "deeployer.json" file and you can deploy easily to a Kubernetes cluster, or to a single server with docker-compose.

Deeployer's goal is not to be 100% flexible (you have Kubernetes for that), but rather to ease the deployment process for developers
that do not necessarily master the intricacies of Kubernetes.

It aims to automate a number of processes, including easy backup setup, easy reverse proxy declaration, etc...




## Contributing

Download and install the Jsonnet Bundler: https://github.com/jsonnet-bundler/jsonnet-bundler/releases

Install the dependencies:

```bash
$ jb install
```

Download and install Tanka: https://github.com/grafana/tanka/releases

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
