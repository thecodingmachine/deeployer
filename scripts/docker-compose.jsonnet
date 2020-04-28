(import 'deeployer/docker-compose-generator.libsonnet') +

{
  docker_compose: $.deeployer.generateDockerCompose(std.extVar('config')),
}
