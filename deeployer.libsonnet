{
  containers: {

    local env = std.extVar("env"),
    containers: {



    //Pod1
    mysql: {
      replicas: 1,
      image: 'mysql',
      ports: ['3306'],
      name: 'mysql',

      env: {
        APP_ENV: 'dev',
      },

      host: 'ocs.test.thecodingmachine.com',


      volumes: {
        mysqldata: {
          mountPath: '/var/lib/mysql',
          diskSpace: { Storage: '4Gi' },
        },
      },

      quotas: {
        min: {
          cpu: '100m',
          memory: '64M',
        },
        max: {
          cpu: '1',
          memory: '1G',
        },
      },

        host : env.NAMESPACE+".test.thecodingmachine.com",


    },

        volumes: {
              mysqldata: {
                mountPath : '/var/lib/mysql',
                diskSpace : {'Storage' : '4Gi'}
              },
          },


    // Pod2
    ocs_inventory: {

      replicas: 1,
      image: 'ocsinventory/ocsinventory-docker-image',
      ports: [9090],
      name: 'ocsinventory',

      env: {
        APP_ENV: 'dev',
        MAILER_FROM: 'no-reply@lrobin.test.thecodingmachine.com',
      },


      host: 'ocsng.test.thecodingmachine.com',


      volumes: {


        perlcomdata: {
          mountPath: '/etc/ocsinventory-server',
          diskSpace: '4Gi',
        },
        extensiondata: {
          mountPath: '/usr/share/ocsinventory-reports/ocsreports/extensions',
          diskSpace: '4Gi',
        },
        varlibdata: {
          mountPath: '/var/lib/ocsinventory-reports',
          diskSpace: '4Gi',
        },
        httpdata: {
          mountPath: '/etc/httpd/conf.d',
          diskSpace: '4Gi',
        },
        mysqldata: {
          mountPath: '/var/lib/mysql',
          diskSpace: '4Gi',
        },


        host: "ocsng.test.thecodingmachine.com",

        volumes: {


              'perlcomdata': {
                mountPath: '/etc/ocsinventory-server',
                diskSpace: '4Gi',
              },
              'extensiondata': {
                mountPath: '/usr/share/ocsinventory-reports/ocsreports/extensions',
                diskSpace: '4Gi',
              },
              'varlibdata': {
                mountPath: '/var/lib/ocsinventory-reports',
                diskSpace: '4Gi',
              },
              'httpdata': {
                mountPath: '/etc/httpd/conf.d',
                diskSpace: '4Gi',
              },
              'mysqldata': {
                mountPath: '/var/lib/mysql',
                diskSpace: '4Gi',
              },


          },


        quotas: {
          min: {
            "cpu": "100m",
            "memory": "64M"
          },
          max: {
            "cpu": "1",
            "memory": "1G"
            }
          }




      },


      quotas: {
        min: {
          cpu: '100m',
          memory: '64M',
        },
        max: {
          cpu: '1',
          memory: '1G',
        },
      },


    },


    //Pod3
    php_myadmin: {
      replicas: 1,
      name: 'php_my_9090admin',
      image: 'phpmyadmin',

      ports: [3307],
        ports : [3307],



      env: {
        APP_ENV: 'dev',
      },

      envFrom: {
        secretKeyRef: {
          // Format 'secret_name' : 'key's_value_to_access'
          'Mysql-env-secrets': 'MYSQL_ROOT_PASSWORD',
        },
        configMapKeyRef: {},
      },


      //host: ''

      volumes: {
        mysqldata: {
          mountPath: '/var/lib/mysql',
          diskSpace: '4Gi',
        envFrom: {
              secretKeyRef: {
                // Format 'secret_name' : 'key's_value_to_access'
                'Mysql-env-secrets' : 'MYSQL_ROOT_PASSWORD'
              },
              configMapKeyRef: {},

        },
      },

      quotas: {
        min: {
          cpu: '100m',
          memory: '64M',
        },
        max: {
          cpu: '1',
          memory: '1G',
        },

        //host: ''

        volumes: {
              'mysqldata': {
                mountPath: '/var/lib/mysql',
                diskSpace: '4Gi',
              },
          },

        quotas: {
          min: {
            "cpu": "100m",
            "memory": "64M",
          },
          max: {
            "cpu": "1",
            "memory": "1G"
            }
          }
      }


      },
    },


  },

  //Pod4 ...

}
