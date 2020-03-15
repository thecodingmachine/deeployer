(import 'deeployer/docker-compose-generator.libsonnet') +

{
  docker_compose: $.deeployer.generateDockerCompose({
    containers: {
      php_myadmin: {
        image: 'phpmyadmin',
        host: 'myhost.com',
      },
      mysql: {
        image: 'phpmyadmin',
      },
    },
  }),
}
