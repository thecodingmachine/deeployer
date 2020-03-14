(import 'ksonnet-util/kausal.libsonnet') +
(import 'deeployer/resource_generator.libsonnet') +

{
  generatedConf: $.deeployer.generateResources({
    containers: {
      php_myadmin: {
        image: 'phpmyadmin',

        host: 'myhost.com',
      },
    },
  }),
}
