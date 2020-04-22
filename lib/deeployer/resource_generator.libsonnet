(import 'ksonnet-util/kausal.libsonnet') +

{
  // declaring ressource types
  local deployment = $.apps.v1.deployment,
  local service = $.core.v1.service,
  local ingress = $.extensions.v1beta1.ingress,
  local ingressRule = ingress.mixin.spec.rulesType,
  local container = $.core.v1.container,
  local containerPort = $.core.v1.containerPort,
  local ImagePullSecret = $.apps.v1.deployment.mixin.spec.template.spec.imagePullSecretsType,
  local env = $.core.v1.container.envType,
  local envFrom = $.core.v1.container.envFromSource,
  local volumeMount = $.core.v1.container.volumeMountsType,
  local volume = $.apps.v1.deployment.mixin.spec.template.spec.volumesType,
  local pvc = $.core.v1.persistentVolumeClaim,
  local resources = $.core.v1.container.resourcesType,
  local httpIngressPath = ingressRule.mixin.http.pathsType,

  /**
   * Returns the list of ports to listen to by merging "ports" with the "containerPort" of the host section
   */
  local getPorts = function(container)
    std.set(  // ports are a "set" (an array of unique values)
      (if std.objectHas(container, 'ports') then container.ports else []) +
      // TODO: if host is defined and containerPort is not defined, put port 80 unless "ports" has only 1 element
      if std.objectHas(container, 'host') && std.objectHas(container.host, 'containerPort') then [container.host.containerPort] else []
    ),

  local getHttpPort = function(container, deploymentName)
    if !std.objectHas(container, 'host') then
      error 'Unexpected call to getHttpPort if there is no host: ' + container
    else if std.objectHas(container.host, 'containerPort') then container.host.containerPort
    else
      if getPorts(container) == [] then error 'For container "' + deploymentName + '", host "' + container.host.url + '" needs a port to bind to. Please provide a containerPort in the "host" section.'
      else if std.length(getPorts(container)) > 1 then error ' For service "' + deploymentName + '", there is a host defined but several ports open. Please provide a containerPort in the "host" section.'
      else getPorts(container)[0]
  ,

  /**
   * Returns true of the container passed in parameter requires https, false otherwise
   */
  local containerHasHttps = function(container)
    if std.objectHas(container, 'host') then
      if !std.objectHas(container.host, 'https') then
        false
      else
        if container.host.https == 'disable' then
          false
        else
          true
    else
      false,

  /**
   * Returns true if at least one container requires HTTPS
   */
  local environmentRequiresHttps = function(containers)
      std.length(std.filter(function(containerName) containerHasHttps(containers[containerName]), std.objectFields(containers))) > 0,

  local f = function(deploymentName, data)
    {

      deployment: deployment.new(
                    name=deploymentName,
                    replicas=if (std.objectHas(data, 'replicas')) then data.replicas else 1,
                    containers=[
                      container.new(deploymentName, data.image) +
                      (if std.objectHas(data, 'ports') then container.withPorts([containerPort.new('p' + port, port) for port in data.ports]) else {})
                      +
                      container.withImagePullPolicy('Always') +
                      //container.withEnv([env.mixin.valueFrom.secretKeyRef.withName(key).withKey(data.envFrom.secretKeyRef[key]) for key in std.objectFields(data.envFrom.secretKeyRef) ],) +
                      (if std.objectHas(data, 'env') then
                         container.withEnv([env.new(key, data.env[key]) for key in std.objectFields(data.env)])
                       else {})
                      +
                      (if std.objectHas(data, 'volumes') then
                         container.withVolumeMounts([volumeMount.new(volumeName, mountPath=data.volumes[volumeName].mountPath, readOnly=false) for volumeName in std.objectFields(data.volumes)])
                       else {})
                      +
                      (if std.objectHas(data, 'quotas') then
                         container.mixin.resources.withRequests(data.quotas.min).withLimits(data.quotas.max)
                       else {}),
                    ]
                  ) +
                  deployment.mixin.spec.strategy.withType('Recreate') +
                  deployment.mixin.spec.template.spec.withImagePullSecrets([ImagePullSecret.new() + ImagePullSecret.withName('tcmregistry')],) +
                  // we add the current date to a random label to force a redeployment, even if the container name did not change.
                  // TODO: in the future, we might want to add this timestamp only for images that we are in charge of.
                  deployment.mixin.spec.template.metadata.withLabelsMixin({ deeployerTimestamp: std.extVar('timestamp') }),

      //std.mapWithKey(fv, data.volumes),
    } + (if std.objectHas(data, 'volumes') then {
           deployment+: deployment.mixin.spec.template.spec.withVolumes([volume.fromPersistentVolumeClaim(volumeName, volumeName + '-pvc') for volumeName in std.objectFields(data.volumes)]),
         } else {})
    + (
      if std.objectHas(data, 'ports') then
        { service: $.util.serviceFor(self.deployment) }
      else {}
    )
    + (
      if std.objectHas(data, 'host') then
        {
          service: $.util.serviceFor(self.deployment),
          ingress: ingress.new() +
                   ingress.mixin.metadata.withName('ingress-' + deploymentName) +
                   //ingress.mixin.metadata.withLabels(data.labels)+
                   (if containerHasHttps(data) then
                       ingress.mixin.metadata.withAnnotations({
                        "cert-manager.io/cluster-issuer": "letsencrypt-prod"
                       })
                   else
                       {})

                   +

                   ingress.mixin.spec.withRules([ingressRule.new() +
                                                 ingressRule.withHost(data.host.url) +
                                                 ingressRule.mixin.http.withPaths(
                                                   httpIngressPath.new() +
                                                   httpIngressPath.mixin.backend.withServiceName(deploymentName) +
                                                   httpIngressPath.mixin.backend.withServicePort(getHttpPort(data, deploymentName))
                                                 )],)
                   + if containerHasHttps(data) then
                     {
                       spec+: {
                           tls: [{
                             hosts: [ data.host.url ],
                             secretName: "ingress-secret-" + deploymentName
                           }]
                       }
                     }
                   else
                    {}
        }

      else { service: $.util.serviceFor(self.deployment) }

    ) + (if std.objectHas(data, 'volumes') then {
           pvcs: std.mapWithKey(function(pvcName, pvcData) { apiVersion: 'v1', kind: 'PersistentVolumeClaim' } +
                                                           pvc.mixin.metadata.withName(pvcName + '-pvc') +
                                                           pvc.mixin.spec.withAccessModes('ReadWriteOnce',) +
                                                           pvc.mixin.spec.resources.withRequests(['storage : ' + pvcData.diskSpace]),
                                data.volumes),
         } else {}),

  local issuer = function(config)
    if environmentRequiresHttps(config.containers) then
      {
        issuer: {

          	"apiVersion": "cert-manager.io/v1alpha2",
          	"kind": "Issuer",
          	"metadata": {
          		"name": "letsencrypt-prod"
          	},
          	"spec": {
          		"acme": {
          			"email": if std.objectHas(config, 'config') && std.objectHas(config.config, 'https') && std.objectHas(config.config.https, 'mail') then config.config.https.mail else error "In order to have support for HTTPS, you need to provide an email address in the { \"config\": { \"https\": { \"mail\": \"some@email.com\" } } }",
          			"server": "https://acme-v02.api.letsencrypt.org/directory",
          			"privateKeySecretRef": {
          				"name": "letsencrypt-prod-secret"
          			},
          			"solvers": [
          				{
          					"http01": {
          						"ingress": {
          							"class": "nginx"
          						}
          					}
          				}
          			]
          		}
          	}

        }
      }
    else
      {}
  ,

  deeployer:: {
    generateResources(config):: std.mapWithKey(f, config.containers) + issuer(config)
    ,
  },

}
