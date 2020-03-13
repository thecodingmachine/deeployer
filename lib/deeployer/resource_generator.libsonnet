
(import "ksonnet-util/kausal.libsonnet")+

{
// declaring ressource types
local deployment =  $.apps.v1.deployment,
local service = $.core.v1.service,
local ingress = $.extensions.v1beta1.ingress,
local ingressRule = ingress.mixin.spec.rulesType,
local container = $.core.v1.container,
local containerPort = $.core.v1.containerPort ,
local ImagePullSecret = $.apps.v1.deployment.mixin.spec.template.spec.imagePullSecretsType,
local env = $.core.v1.container.envType,
local envFrom = $.core.v1.container.envFromSource,
local volumeMount = $.core.v1.container.volumeMountsType,
local volume = $.core.v1.deployment.volumesType,
local pvc = $.core.v1.persistentVolumeClaim,
local resources = $.core.v1.container.resourcesType,

local f = function(deploymentName, data) {
                        local fv = function(volumeName, volumeData) deployment.mixin.spec.template.spec.withVolumes([volume.fromPersistentVolumeClaim(std.objectFields(data.volumeMounts),"-pvc"+volumeName)]),                               
                        deployment: deployment.new(
                                        name=data.name,
                                          replicas=data.replicas,
                                           containers=[container.new(data.name, data.image)+
                                                         (if std.objectHas(data, 'ports') then container.withPorts([containerPort.new('p'+port, port) for port in data.ports]) else {})
                                                         +
                                                        container.withImagePullPolicy('Always') + 
                                                        container.withEnv([env.mixin.valueFrom.secretKeyRef.withName(key).withKey(data.envFrom.secretKeyRef[key]) for key in std.objectFields(data.envFrom.secretKeyRef) ],) +
                                                        container.withEnv([env.new(key, data.env[key]) for key in std.objectFields(data.env)])+
                                                        container.withVolumeMounts([volumeMount.new(std.objectFields(data.volumeMounts) , mountPath=data.volumeMounts[key].mountPath,readOnly=false) for key in std.objectFields(data.volumeMounts) ]),
                                                        container.mixin.resources.withRequests(data.quotas.min).withLimits(data.quotas.max) ],                                                       
                                             podLabels=data.labels,
                                        )+ 
                        deployment.mixin.spec.strategy.withType("Recreate")+
                        deployment.mixin.spec.template.spec.withImagePullSecrets([ImagePullSecret.new() + ImagePullSecret.withName("tcmregistry")],)+
                        std.mapwithKey(fv, data.volumeMounts),  
                        

 } + (if std.objectHas(data, 'ports') then 
        (if std.objectHas(data, 'host') then 
        { service: $.util.serviceFor(self.deployment),
          ingress: ingress.new()+
                      ingress.mixin.metadata.withName("ingress-"+deploymentName)+
                          //ingress.mixin.metadata.withLabels(data.labels)+
                              //ingress.mixin.metadata.withAnnotations(data.annotations)+
                                  ingress.mixin.spec.backend.withServiceName("ingress-"+deploymentName+'-service').withServicePort([containerPort.new('p'+port, port) for port in data.ports],)+
                                      ingress.mixin.spec.withRules([ingressRule.new()+ 
                                            ingressRule.withHost(data.host)+
                                                  ingressRule.mixin.http.withPaths('/')],),}
    
      else { service : $.util.serviceFor(self.deployment), })
 
      else if !std.objectHas(data, 'ports') then error " Can't create container by deployment without any port with deeployer "
        else if std.objectHas(data, 'host') then error " Can't expose service by host \"" + data.host + "\" without a port "
          else if std.length(data.ports) > 1 then error " For service \"" + deploymentName + "\", there is a host defined but several ports open. We don't support this case yet. "
              else if std.length(data.ports) == 0 then error " There is no port defined for service \"" + deploymentName + "\""
                else if std.objectHas(data, 'ports') then {}
) + {
  pvcs: std.mapWithKey(function(pvcName, pvcData) pvc.new() +
                                pvc.mixin.metadata.withName(pvcName+"-pvc") +
                                pvc.mixin.spec.withAccessModes("ReadWriteOnce",)+
                                pvc.mixin.spec.resources.withRequests(["storage : "+pvcData.diskSpace]),
                                 data.volumeMounts),
},
  


deeployer:: {
  generateResources(config):: std.mapWithKey(f,config.containers),
},


}