{
  local env = std.extVar('env'),
  local environment = env.CI_COMMIT_REF_SLUG,

  //local url = if namespace == "<prod_branch>" then "<prod_url>" else namespace+".<projet_name>.test.thecodingmachine.com",
  local url = 'econocom.test.thecodingmachine.com',
  version: '1.0',
  '$schema': 'https://raw.githubusercontent.com/thecodingmachine/deeployer/master/deeployer.schema.json',
  containers: {
    api: {
      image: 'git.thecodingmachine.com:444/tcm-projects/econocom/api:' + environment,
      host: {
        url: environment + '.api.' + url,
      },
      ports: [80],
      env: {
        APP_ENV: 'prod',
        DATABASE_URL: env.DATABASE_URL,
        APP_SECRET: env.APP_SECRET,
      },
    },

    web: {
      image: 'git.thecodingmachine.com:444/tcm-projects/econocom/web:' + environment,
      host: {
        url: environment + '.' + url,
      },
      ports: [80],
    },

    mysql: {
      image: 'thecodingmachine/mysql:8.0-v1',
      ports: [3306],
      env: {
        MYSQL_USER: env.DB_USERNAME,
        MYSQL_ROOT_PASSWORD: env.DB_ROOT_PASSWORD,
        MYSQL_PASSWORD: env.DB_PASSWORD,
        MYSQL_DATABASE: env.DB_DATABASE,
      },
      volumes: {
        mysql_data: {
          diskSpace: '1G',
          mountPath: '/var/lib/mysql',
        },
      },
    },

    phpmyadmin: {
      image: 'phpmyadmin/phpmyadmin',
      host: {
        url: environment + '.phpmyadmin.' + url,
      },
      ports: [80],
      env: {
        PMA_HOST: 'mysql',
        PMA_USER: env.DB_USERNAME,
        PMA_PASSWORD: env.DB_PASSWORD,
      },
    },

    mongo: {
      image: 'mongo:3',
      ports: [27017],
      volumes: {
        mondo_data: {
          diskSpace: '1G',
          mountPath: '/var/lib/mysql',
        },
      },
    },

    elasticsearch: {
      image: 'docker.elastic.co/elasticsearch/elasticsearch-oss:6.8.5',
      ports: [9200],
      env: {
        ES_JAVA_OPTS: '-Xms512m -Xmx512m',
      },
      volumes: {
        es_data: {
          diskSpace: '1G',
          mountPath: '/usr/share/elasticsearch/data',
        },
      },
    },

    graylog: {
      image: 'graylog/graylog:3.2',
      host: {
        url: environment + '.graylog.' + url,
      },
      ports: [9000],
      env: {
        GRAYLOG_PASSWORD_SECRET: env.GRAYLOG_PASSWORD_SECRET,
        // Password: same password of database
        GRAYLOG_ROOT_PASSWORD_SHA2: env.GRAYLOG_ROOT_PASSWORD_SHA2,
        GRAYLOG_HTTP_EXTERNAL_URI: 'http://graylog.' + url + ':9000/',
      },
      volumes: {
        graylog_journal: {
          diskSpace: '1G',
          mountPath: '/usr/share/elasticsearch/data',
        },
      },
    },

    config: {
      registryCredentials: {
        'git.thecodingmachine.com:444': {
          user: env.CI_ACCOUNT,
          password: env.CI_PASSWD,
        },
      },
    },
  },
}
