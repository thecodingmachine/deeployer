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
    k8sextensions(k8sConf):: k8sConf + {
              back+: {
                deployment+: {
                  spec+: {
                    template+: {
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
