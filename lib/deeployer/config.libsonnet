
(import "ksonnet-util/kausal.libsonnet")+
(import "deeployer.libsonnet")+

{
local config = import 'config.libsonnet',
local c = config.containers,

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


local f = function(deploymentName, data) {
                        deployment: deployment.new(
                                        name=data.name,
                                          replicas=1,
                                           containers=[container.new(data.name, data.image)+
                                                         (if std.objectHas(data, 'ports') then container.withPorts([containerPort.new('p'+port, port) for port in data.ports]) else {})
                                                         +
                                                        container.withImagePullPolicy('Always') + 
                                                        container.withEnv([env.mixin.valueFrom.secretKeyRef.withName(key).withKey(data.envFrom.secretKeyRef[key]) for key in std.objectFields(data.envFrom.secretKeyRef) ],) +
                                                        container.withEnv([env.new(key, data.env[key]) for key in std.objectFields(data.env)]) ],                                                       
                                             podLabels=data.labels,
                                        )+ 
                        deployment.mixin.spec.strategy.withType("Recreate")+
                        deployment.mixin.spec.template.spec.withImagePullSecrets([ImagePullSecret.new() + ImagePullSecret.withName("tcmregistry")],),  

                        

 } + (if std.objectHas(data, 'ports') then {
                        service: $.util.serviceFor(self.deployment),
 } else {})
  + (if std.objectHas(data, 'host') then 
      //local ingressPort = -1,
      (if !std.objectHas(data, 'ports') || std.length(data.ports) == 0 then
        error "There is no port defined for service \"" + deploymentName + "\""
      else (if std.length(data.ports) > 1 then
        error "For service \"" + deploymentName + "\", there is a host defined but several ports open. We don't support this case yet."
      else {
                        ingress: ingress.new()+
                                    ingress.mixin.metadata.withName("ingress-"+deploymentName)+
                                    //ingress.mixin.metadata.withLabels(data.labels)+
                                    //ingress.mixin.metadata.withAnnotations(data.annotations)+
                                    ingress.mixin.spec.backend.withServiceName("ingress-"+deploymentName+'-service').withServicePort([containerPort.new('p'+port, port) for port in data.ports],)+
                                    ingress.mixin.spec.withRules([ingressRule.new()+ 
                                                                    ingressRule.withHost(data.host)+
                                                                        ingressRule.mixin.http.withPaths('/')],)
      }))                                                      
  else {})
 
 ,

//  local ds = function(deploymentName, data) {
//                         deployment: deployment.new(
//                                         name=data.name,
//                                           replicas=1,
//                                            containers=[container.new(data.name, data.image)+
//                                                         container.withPorts([containerPort.new('p'+port, port) for port in data.ports])+
//                                                         container.withImagePullPolicy('Always') + 
//                                                         container.withEnv([env.mixin.valueFrom.secretKeyRef.withName(key).withKey(data.envFrom.secretKeyRef[key]) for key in std.objectFields(data.envFrom.secretKeyRef) ],) +
//                                                         container.withEnv([env.new(key, data.env[key]) for key in std.objectFields(data.env)]) ],                                                       
//                                              podLabels=data.labels,
//                                         )+ 
//                         deployment.mixin.spec.strategy.withType("Recreate")+
//                         deployment.mixin.spec.template.spec.withImagePullSecrets([ImagePullSecret.new() + ImagePullSecret.withName("tcmregistry")],),  

                        
//                         service: $.util.serviceFor(self.deployment),
//  } ,

//  local d = function(deploymentName, data) {
//                         deployment: deployment.new(
//                                         name=data.name,
//                                           replicas=1,
//                                            containers=[container.new(data.name, data.image)+
//                                                         container.withPorts([containerPort.new('p'+port, port) for port in data.ports])+
//                                                         container.withImagePullPolicy('Always') + 
//                                                         container.withEnv([env.mixin.valueFrom.secretKeyRef.withName(key).withKey(data.envFrom.secretKeyRef[key]) for key in std.objectFields(data.envFrom.secretKeyRef) ],) +
//                                                         container.withEnv([env.new(key, data.env[key]) for key in std.objectFields(data.env)]) ],                                                       
//                                              podLabels=data.labels,
//                                         )+ 
//                         deployment.mixin.spec.strategy.withType("Recreate")+
//                         deployment.mixin.spec.template.spec.withImagePullSecrets([ImagePullSecret.new() + ImagePullSecret.withName("tcmregistry")],),  


deeployer : std.mapWithKey(f,c) ,

// local func = checkConfigValues(c) {
//   checking : [if c.key.port==' ' then [deeployer : std.mapWithKey()] for key in std.objectFields(c)   ] ,
// },

}


