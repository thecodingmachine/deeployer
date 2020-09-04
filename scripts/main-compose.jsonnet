
    local generatedCompose = (import "/tmp/docker-compose.json") ;
    local deeployer = (import "/tmp/dynamic-function.libsonnet");



   // deeployerConfig.config.dynamic.composeExtension(generatedCompose)

   deeployer.composeExtension(generatedCompose)

// functionToExecute(generatedCompose)



//toMergeContent.composeExtension(generatedCompose)

// local merger=  function(generatedCompose, toMergeContent){
// composeExtension(generatedCompose)::
//    {local finalCompose= generatedCompose + toMergeContent}
// };



// generated : (import "/tmp/dynamic-function.libsonnet")

