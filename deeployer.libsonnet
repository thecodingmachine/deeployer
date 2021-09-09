{
  version: '1.0',
  '$schema': '../deeployer.schema.json',
  containers: {
    mysql: {
      image: 'mysql:8',
      env: {
        MYSQL_ROOT_PASSWORD: 'ocs',
      },
      volumes: {
        data: {
          diskSpace: '1G',
          mountPath: '/var/lib/mysql',
        },
      },
    },
    phpmyadmin: {
      image: 'phpmyadmin/phpmyadmin',
      env:
        {
          PMA_HOST: 'mysql',
        },
      host: {
        url: 'phpmyadmin.tcm-test.tk',
        https: 'enable',
      },

    },
  },
  config: {
    https: {
      mail: 'test@thecodingmachine.com',
    },
    dynamic: '\n      composeExtension(composeConfig)::\n      composeConfig + {\n        services+: {\n          mysql+: {\n            "labels": ["testing_label"],\n                  "command": ["date"],\n          },\n        },\n      },',
  },
}
