(import 'deeployer/docker-compose-generator.libsonnet') +

{
  docker_compose: $.deeployer.generateDockerCompose({
    containers: {
      php_myadmin: {
        image: 'phpmyadmin',
      },
      mysql: {
        image: 'phpmyadmin',
      },
    },
  }),
}
