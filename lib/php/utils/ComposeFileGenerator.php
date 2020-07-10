<?php


namespace App\utils;


class ComposeFileGenerator
{
    public const TmpFilePath = '/tmp/docker-compose.json';
    
    public function createDockerComposeConfig(array $deeployerConfig): array
    {
        $dockerComposeConfig = ['a' => 1];

        $dockerComposeConfig['version'] = $deeployerConfig['version'];

        $dockerComposeConfig['services'] = [
            'traefik' => $this->createTraefikConf()
        ];
        foreach ($deeployerConfig['containers'] as $serviceName => $containerConfig) {
            $serviceConfig = $this->createServiceConfig($containerConfig);

            if (isset($containerConfig['host'])) {
                $serviceConfig['labels'] = $this->createTraefikLabels($containerConfig['host']);
            }

            $dockerComposeConfig['services'][$serviceName] = $serviceConfig;
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
    
    public function createServiceConfig(array $containerConfig): array
    {
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
            foreach ($containerConfig['volumes'] as $mountValue) {
                $dockerComposeConfig['volumes'][] = $mountValue;
            }
        }
        
        return $dockerComposeConfig;
    }
    
    public function createTraefikLabels(array $hostConfig): array
    {
        if (!isset($hostConfig['url'])) {
            throw new \RuntimeException('No parameter url found in the host config: '. var_export($hostConfig, true));
        }
        $host = $hostConfig['url'];
        return [
            'traefik.enable=true',
            "traefik.http.routers.front_router.rule=Host(`$host`)"
        ];
    }

}