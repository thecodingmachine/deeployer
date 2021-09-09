local generatedCompose = (import '/tmp/docker-compose.json');
local deeployer = (import '/tmp/dynamic-function.libsonnet');


deeployer.composeExtension(generatedCompose)
