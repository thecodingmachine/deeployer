(import 'ksonnet-util/kausal.libsonnet') +
(import 'deeployer/resource_generator.libsonnet') +

{
  generatedConf: $.deeployer.generateResources({
    containers: {
      php_myadmin: {
        image: 'phpmyadmin',
        ports: [80],
        host: 'myhost.com',
      },
    },
  }),
}
