{
  local env = std.extVar("env"),
  local environment = env.CI_COMMIT_REF_SLUG,

  #local url = if namespace == "<prod_branch>" then "<prod_url>" else namespace+".<projet_name>.test.thecodingmachine.com",
  local url= "pnas-extranet.test.thecodingmachine.com",

  "$schema": "https://raw.githubusercontent.com/thecodingmachine/deeployer/master/deeployer.schema.json",
  "containers": {
     "api": {
       "image": "git.thecodingmachine.com:444/tcm-projects/pnas-extranet/api:"+environment,
       "host": {
         "url": environment+".api."+url,
       },
       "ports": [80],
       "env": {
         "APP_ENV": "dev",
         "DATABASE_URL": env.DATABASE_URL,
         "APP_SECRET" : env.APP_SECRET,
         "MAILER_URL": "smtp://mailcatcher:1025?encryption=&auth_mode=",
         "MAIL_SENDER": "no-reply@pnas.localhost",
         "MAIL_RECEIVER": "contact@pnas.localhost"
       }
     },
    "front": {
      "image": "git.thecodingmachine.com:444/tcm-projects/pnas-extranet/front:"+environment,
      "host": {
        "url": environment+"."+url,
      },
      "ports": [80],
      "env": {
        "REACT_APP_API_URL": environment+".api."+url,
        "REACT_APP_API_PORT": "80",
        "REACT_APP_PNAS_STREET_ADDRESS_IFRAME_SRC" : "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2623.9330420356473!2d2.322836951898004!3d48.87855297918768!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x47e66e4ac31e6481%3A0x9d192e4b0be8f01b!2s56%20Rue%20de%20Londres%2C%2075009%20Paris!5e0!3m2!1sfr!2sfr!4v1586862581099!5m2!1sfr!2sfr"
      }
    },
    "mailcatcher": {
      "image": "schickling/mailcatcher",
      "host": {
        "url": environment+".mailcatcher."+url,
      },
      "ports": [1080]
    },
    "mysql": {
      "image": "thecodingmachine/mysql:8.0-v1",
      "ports": [3306]
    }
  },
  "config": {
    "registryCredentials": {
      "git.thecodingmachine.com:444" : {
        "user": env.CI_ACCOUNT_PNAS,
        "password": env.CI_PASSWD
      }
     }
  }
}