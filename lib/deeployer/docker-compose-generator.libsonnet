{
  local generateContainer = function(deploymentName, data)
    {
      image: data.image,
    },

  local hasHost = function(containers) std.length(std.filter
                                                  (
    function(deploymentName)
      std.objectHas(containers[deploymentName], 'host'),
    std.objectFields(containers)
  )) > 0,

  deeployer+:: {
    generateDockerCompose(config):: {
      version: '3',

      services: std.mapWithKey(generateContainer, config.containers) +
                if hasHost(config.containers) then {
                  traefik: {
                    image: 'traefik:2',
                  },
                } else {},
    },
  },


}
