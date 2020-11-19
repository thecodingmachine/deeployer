<?php


namespace App\utils;


class ComposeFileGenerator
{
    public const TmpFilePath = '/tmp/docker-compose.json';
    public const volumesToGenerate = '';



    public function createFile(array $deeployerConfig): string
    {
        $dockerFileConfig = $this->createDockerComposeConfig($deeployerConfig);
            $returnCode = file_put_contents(self::TmpFilePath, json_encode($dockerFileConfig));
            if ($returnCode === false) {
                throw new \RuntimeException('Error when trying to create the docker-compose file');
            }
        if (isset($deeployerConfig['config']['dynamic'])) {
            $this->generateDynamicConfigFunction($deeployerConfig['config']['dynamic']);
            $this->editConfig();

        }
        // exit;
        //dynamically edit config file with libsonnet

        return self::TmpFilePath;
    }

    public function editConfig(): void
    {
        $output = "";
        exec ("jsonnet /home/mika/tanka/deeployer/scripts/main-compose.jsonnet", $output);
        file_put_contents(self::TmpFilePath, $output);
    }

    private function generateDynamicConfigFunction(string $dynamicFunctionConfig): void
    {
        $dynamicFunction = "{\n$dynamicFunctionConfig\n}\n";
        // $dynamicFunction = $dynamicFunctionConfig;
        file_put_contents("/tmp/dynamic-function.libsonnet", $dynamicFunction);
    }


    private function httpsChecker(array $deeployerConfig): bool
    {
        foreach ($deeployerConfig['containers'] as $serviceName => $service){
            if (isset ($service['host']['https']) && $service['host']['https'] == true){
                return true;
            }
        }
        return false;
    }

    private function httpChecker(array $deeployerConfig): bool
    {
        foreach ($deeployerConfig['containers'] as $serviceName => $service){
            if (isset ($service['host']) ){
                return true;
            }
        }
        return false;
    }

    public function createTraefikConf(array $deeployerConfig ): array
    {
       $HttpTraefikConfig=[
            "image" => "traefik:2.0",
            "command" => [
                "--global.sendAnonymousUsage=false",
                "--log.level=DEBUG",
                "--providers.docker=true",
                "--providers.docker.exposedbydefault=false",
                "--providers.docker.swarmMode=false",
                "--entrypoints.web.address=:80",
                // "--providers.docker.endpoint=\"unix:///var/run/docker.sock\"",
            ],
            "ports" => [
                "80:80",
            ],
            "volumes" => [
                "/var/run/docker.sock:/var/run/docker.sock",
            ]
        ];

        if ( $this-> httpsChecker($deeployerConfig) == true){
            $HttpTraefikConfig['ports'][]= '443:443';
            if (!isset ($deeployerConfig['config']['https']['mail'])) {
                throw new \RuntimeException('Error you need to set in the config section of your file the mail field');
            }
            $HttpTraefikConfig['command'][]= "--entrypoints.websecured.address=:443";
            $HttpTraefikConfig['command'][]= "--certificatesresolvers.letsencrypt.acme.email=".$deeployerConfig['config']['https']['mail'];
            $HttpTraefikConfig['command'][]= "--certificatesresolvers.letsencrypt.acme.storage=/acme.json";
            $HttpTraefikConfig['command'][]= "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web";
            $HttpTraefikConfig['command'][]= "--certificatesresolvers.letsencrypt.acme.caServer=https://acme-staging-v02.api.letsencrypt.org/directory";
            $HttpTraefikConfig['volumes'][]= "./conf/traefik/acme.json:/acme.json";
        }
        return $HttpTraefikConfig;
    }

    public function createTraefikLabels(array $hostConfig, string $serviceName): array
    {
        $host = $hostConfig['url'];
        $httpLabels = [
            'traefik.enable=true',
            "traefik.http.routers.$serviceName.rule=Host(`$host`)"
        ];
        if (isset($hostConfig['https']) && $hostConfig['https'] == "enable") {
            $httpLabels[] = "traefik.http.routers.$serviceName.entrypoints=websecured";
        }
        return $httpLabels;
    }

    public function createServiceConfig(array $containerConfig): array
    {

        //What is the utility of the next 2 lines ??
        $dockerComposeConfig = [
            'image' => $containerConfig['image'],
            // 'ports' => $containerConfig['ports'],
            // 'environment' => $containerConfig['env'],
            // 'volumes' => $containerConfig['volumes']
        ];

        //Added ports
        if (isset($containerConfig['ports'])) {
            $dockerComposeConfig['ports'] = [];
            foreach ($containerConfig['ports'] as $portsSet => $portsValue) {
                $dockerComposeConfig['ports'][$portsSet] = $portsValue;
            }
        }

        if (isset($containerConfig['env'])) {
            $dockerComposeConfig['environment'] = [];
            foreach ($containerConfig['env'] as $envVariableName => $envVariableValue) {
                $dockerComposeConfig['environment'][$envVariableName] = $envVariableValue;
            }
        }

        // Set volumes for container
        if (isset($containerConfig['volumes'])) {
            $dockerComposeConfig['volumes'] = [];
            foreach ($containerConfig['volumes'] as $volumeName => $volumeValue) {
                 $mountPath = $volumeValue['mountPath'];
                 $dockerComposeConfig['volumes'][] = $volumeName.":".$mountPath;
            }
        }

        // Setting command feature
        if (isset($containerConfig['command'])) {
            $dockerComposeConfig['command'] = [];
            foreach ($containerConfig['command'] as $commandValue) {
                 $dockerComposeConfig['command'] = $commandValue;
            }
        }

        return $dockerComposeConfig;
    }

    // Create volumes
    public function createVolumeConfig( array $deeployerConfig ): array
    {
        $driver = ['driver' => 'local'];
        $volumesConfig = [] ;
        foreach ($deeployerConfig['containers'] as $serviceName => $service) {
            if (isset($service['volumes'])) {
                foreach ($service['volumes'] as $volumeName => $volume ) {
                    $volumesConfig[$volumeName]= $driver;
                }
            }
        }
        return $volumesConfig;
    }

    public function createDockerComposeConfig(array $deeployerConfig ): array
    {
        $dockerComposeConfig = [];

        $dockerComposeConfig['version'] = "3.3";

        if ($this->httpChecker($deeployerConfig)== true){
            $dockerComposeConfig['services'] = [
                'traefik' => $this->createTraefikConf($deeployerConfig)
            ];
        }

        foreach ($deeployerConfig['containers'] as $serviceName => $containerConfig) {
            $serviceConfig = $this->createServiceConfig($containerConfig);
            if ($this->httpChecker($deeployerConfig)== true){
                if (isset ($containerConfig['host'])) {
                    $serviceConfig['labels'] = $this->createTraefikLabels($containerConfig['host'], $serviceName);
                }
            }
            $dockerComposeConfig['services'][$serviceName] = $serviceConfig;
        }

        $volumesConfig = $this->createVolumeConfig($deeployerConfig); // Need to put this in a variable
        if (!empty($volumesConfig)){
        $dockerComposeConfig['volumes'] = $volumesConfig ;}

        return $dockerComposeConfig;
    }
}