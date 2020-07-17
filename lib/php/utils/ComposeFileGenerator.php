<?php


namespace App\utils;


class ComposeFileGenerator
{
    public const TmpFilePath = '/tmp/docker-compose.json';
    
    public function createDockerComposeConfig(array $deeployerConfig): array
    {
        $dockerComposeConfig = [];

        $disksToCreate = [];

        $dockerComposeConfig['version'] = $deeployerConfig['version'];

        $dockerComposeConfig['services'] = [
            'traefik' => $this->createTraefikConf()
        ];
        foreach ($deeployerConfig['containers'] as $serviceName => $containerConfig) {
            $serviceConfig = $this->createServiceConfig($containerConfig, $disksToCreate);

            if (isset($containerConfig['host'])) {
                $serviceConfig['labels'] = $this->createTraefikLabels($containerConfig['host']);
            }

            $dockerComposeConfig['services'][$serviceName] = $serviceConfig;
        }


        foreach (volumesToGenerate as $disksToCreate) {
            //todo create the config for volume generation
        }
        return $dockerComposeConfig;
    }

    public function createFile(array $deeployerConfig): string
    {
        $dockerFileConfig = $this->createDockerComposeConfig($deeployerConfig);
        $returnCode = file_put_contents(self::TmpFilePath, json_encode($dockerFileConfig));
        if ($returnCode === false) {
            throw new \RuntimeException('Error when trying to create the docker-compose file');
        }
        return self::TmpFilePath;
    }
    
    public function createTraefikConf(): array
    {
        //todo allow configuration of the traefik config?
        return [
            "image" => "traefik:2.0",
            "command" => [
                "--providers.docker",
                "--providers.docker.exposedByDefault=false",
            ],
            "ports" => [
                "80:80",
            ],
            "volumes" => [
                "/var/run/docker.sock:/var/run/docker.sock",
            ]
        ];
    }
    
    public function createServiceConfig(array $containerConfig, array &$disksToCreate): array
    {
        createTraefikConf();
        $volumesToGenerate = [];
        //todo app more options
        $dockerComposeConfig = [
            'image' => $containerConfig['image']
        ];
         
        if (isset($containerConfig['env'])) {
            $dockerComposeConfig['environment'] = [];
            foreach ($containerConfig['env'] as $envVariableName => $envVariableValue) {
                $dockerComposeConfig['environment'][$envVariableName] = $envVariableValue;
            }
        }

        if (isset($containerConfig['volumes'])) {
            $dockerComposeConfig['volumes'] = [];
            foreach ($containerConfig['volumes'] as $volumeConfig) {
                $volumeToCreateConfig = new VolumeConfig($volumeConfig);
                //todo
                $dockerComposeConfig['volumes'][] = $volumeToCreate['toString'];
                if ($volumeToCreate['needsToBeGenerated']) {
                    $disksToCreate[$volumeToCreate['diskKey']] = $volumeToCreate['diskConfig'];
                }
            }
        }
        
        return $dockerComposeConfig;
    }
    
    public function createTraefikLabels(array $hostConfig): array
    {
        $host = $hostConfig['url'];
        return [
            'traefik.enable=true',
            "traefik.http.routers.front_router.rule=Host(`$host`)"
        ];
    }

} 