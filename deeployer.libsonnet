{
  local env = std.extVar('env'),
  containers: {


    //Pod1
    mysql: {
      replicas: 1,
      image: 'mysql',
      ports: ['3306'],

      env: {
        APP_ENV: 'dev',
      },

      host: env.NAMESPACE + '.test.thecodingmachine.com',


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

    },


    // Pod2

  },

  //Pod4 ...

  // config: {
  //   registryCredentials:{
  //     secret_name: "",
  //     url: "",
  //     user: "",
  //     password: "",
  //   },
  // },

}