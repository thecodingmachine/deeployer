{
  "containers": {
    "phpmyadmin": {
      "image": "phpmyadmin",
      "ports": [
        80
      ],
      "host": {
        "url": "myhost.com"
      }
    }
  },
  "config": {
    k8sextension(k8sConf)::
            k8sConf + {
              phpmyadmin+: {
                deployment+: {
                  spec+: {
                    template+: {
                      metadata+: {
                        annotations+: {
                          "prometheus.io/port": "8080",
                          "prometheus.io/scrape": "true"
                        }
                      }
                    }
                  }
                }
              }
            }
  }
}
