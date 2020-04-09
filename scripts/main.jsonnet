// environments/prom-grafana/prod
(import 'ksonnet-util/kausal.libsonnet') +
(import "deeployer/resource_generator.libsonnet")+

{
local config = std.extVar('config'),
local deeployer = $.deeployer,


generatedConf: deeployer.generateResources(config)

}
