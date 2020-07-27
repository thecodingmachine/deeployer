(import 'ksonnet-util/kausal.libsonnet') +
(import 'deeployer/resource_generator.libsonnet') +

{
  local config = import '../../deeployer.libsonnet',
  local deeployer = $.deeployer,


  generatedConf: deeployer.generateResources(config),

}
