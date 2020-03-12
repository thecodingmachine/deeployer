{
    containers: {   


      //Pod1
      mysql: {
        replicas: 1,
        image: "mysql",
        ports: ["3306",],
        name: "mysql",

        labels: {
              'app' : 'mysql',
              'database_type' : 'sql'
        },

        annotations: {},

        env: {
              APP_ENV : "dev"
        },

        envFrom: {
              secretKeyRef: {
                // Format 'secret_name' : 'key's_value_to_access' 
                'Mysql-env-secrets' : 'MYSQL_ROOT_PASSWORD'
              },
              configMapKeyRef: {},
        },

        host : "ocs.test.thecodingmachine.com",


        volumeMounts: {
              'mysqldata': {
                mountPath : '/var/lib/mysql',
                diskSpace : {'Storage' : '4Gi'}  ,
                persistent : 'yes',  // type 'no' if you don't need any pvc !
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

        

      // Pod2
      ocs_inventory: {

        replicas: 1,
        image: "ocsinventory/ocsinventory-docker-image",
        ports: [9090],
        name: "ocsinventory",
        persistent : 'yes',  // type 'no' if you don't need any pvc !

        labels: {
            'app' : 'ocs'
        },

        annotations: {},

        env: {
            'APP_ENV':'dev',
            'MAILER_FROM': 'no-reply@lrobin.test.thecodingmachine.com'
        },

        envFrom: {
            secretKeyRef: {
                // Format 'secret_name' : 'key's_value_to_access' 
                'Ocs-env-secrets' : 'AWS_SECRET_ACCESS_KEY'
              },
            configMapKeyRef: {},
        },

        host: "ocsng.test.thecodingmachine.com",
   
        volumeMounts: {


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



      //Pod3
      php_myadmin: {
        replicas: 1,
        name : "php_my_9090admin",
        image: "phpmyadmin",

        labels : {
              'app' : 'phpmyadmin'
        },

        annotations: {
          "kubernetes.io/ingress.global-static-ip-name": "web-static-ip"
        },

        ports : [3307],
      

        env: {
              "APP_ENV" : "dev"
        },

        envFrom: {
              secretKeyRef: {
                // Format 'secret_name' : 'key's_value_to_access' 
                'Mysql-env-secrets' : 'MYSQL_ROOT_PASSWORD'
              },
              configMapKeyRef: {},
        },

        //host: ''

        volumeMounts: {
              'mysqldata': {
                mountPath: '/var/lib/mysql',
                diskSpace: '4Gi',
                persistent : 'yes',  // type 'no' if you don't need any pvc !
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

      //Pod4 ...
  
}
