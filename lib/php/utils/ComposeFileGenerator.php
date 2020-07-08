<?php


namespace App\utils;


class ComposeFileGenerator
{
    public const TmpFilePath = '/tmp/docker-compose.json';
    
    public function createConfig(array $config): array
    {
        $json = [];

        $json['version'] = $config['version'];

        $json['services'] = [
            'traefik' => $this->createTraefikConf()
        ];
        foreach ($config['containers'] as $serviceName => $containerConfig) {
            $serviceConfig = $this->createServiceConfig($containerConfig);

            if (isset($containerConfig['host'])) {
                $serviceConfig['labels'] = $this->createTraefikLabels($containerConfig['host']);
            }

            $json['services'][$serviceName] = $serviceConfig;
        }
        return $json;
    }

    public function createFile(array $config): string
    {
        $json = $this->createConfig($config);        
        $returnCode = file_put_contents(self::TmpFilePath, $json);
        if ($returnCode === false) {
            throw new \RuntimeException('Error when trying to create the docker-compose file');
        }
        return self::TmpFilePath;
    }
    
    public function createTraefikConf(): array
    {
        //todo: create traefik container
        return [];
    }
    
    public function createServiceConfig(array $containerConfig): array
    {
        //todo app more options
        return [
            'image' => $containerConfig['image']
        ];
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