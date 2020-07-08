<?php


namespace App\utils;


class ComposeFileGenerator
{
    public const TmpFilePath = '/tmp/docker-compose.json';


    /**
     * @param mixed[] $config
     * @return mixed[]
     */
    public function createConfig(array $config): array
    {
        $json = [];

        $json['version'] = $config['version'];

        $json['services'] = [
            //todo: add traefik container
        ];
        foreach ($config['containers'] as $serviceName => $containerConfig) {
            $serviceConfig = [
                'image' => $containerConfig['image']
            ];

            if (isset($containerConfig['host'])) {
                $host = $containerConfig['host']['url']; //todo: throw exception if not found
                $traefikLabels = [
                    'traefik.enable=true',
                    "traefik.http.routers.front_router.rule=Host(`$host`)"
                ];
                $serviceConfig['labels'] = $traefikLabels;
            }

            $json['services'][$serviceName] = $serviceConfig;
        }
        return $json;
    }

    /**
     * @param mixed[] $config
     */
    public function createFile(array $config): string
    {
        $json = $this->createConfig($config);        
        $returnCode = file_put_contents(self::TmpFilePath, $json);
        if ($returnCode === false) {
            throw new \RuntimeException('Error when trying to create the docker-compose file');
        }
        return self::TmpFilePath;
    }

}