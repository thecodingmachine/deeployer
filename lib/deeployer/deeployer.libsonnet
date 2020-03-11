{
    containers: {    
      //Pod1
      mysql: {

        image: "mysql",
        ports: [3306],
        name: "mysql",

        labels: {

              'app' : 'mysql',
              'database_type' : 'sql'
        
        },

        annotations: {

        },

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

        ingress: {
                   name: "",
                   host: "",
                   path: [],
        },

        volumeMounts: {
              mysqldata: {
                mountPath: '/var/lib/mysql',
                diskSpace: '4Gi',
              },
          },

        withService:'yes',
        withIngress:'no',

      },
      // Pod2
      ocs_inventory: {


        image: "ocsinventory/ocsinventory-docker-image",
        ports: [9090, 80],
        name: "ocsinventory",

        labels: {

            'app' : 'ocs'
        
        },

        annotations: {

        },

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
        /*ingress: {
                  name: "ocs-ingress",
                  host: "ocsng.test.thecodingmachine.com",
                  path: ["/",],
        },*/
   
        volumeMounts: {


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
         
         
          },

      },
      //Pod3
      php_myadmin: {
        name : "php_my_admin",
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

        ingress: {
                  name: "",
                  host: "",
                  path: [],
        },

        volumeMounts: {

              mysqldata: {
                mountPath: '/var/lib/mysql',
                diskSpace: '4Gi',
              },
          },
      }

      
      },

      //Pod4}
  
}
