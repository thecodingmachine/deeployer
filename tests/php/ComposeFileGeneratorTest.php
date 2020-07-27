<?php


namespace App\Tests;


use App\utils\ComposeFileGenerator;
use PHPUnit\Framework\TestCase;

class ComposeFileGeneratorTest extends TestCase
{
    public function testTraefikConfig(): void
    {
        $generator = new ComposeFileGenerator();
        $result = $generator->createTraefikConf();
        $expected = [
            "image" => "traefik:2.0",
            "command" => [
                "--providers.docker",
                "--providers.docker.exposedByDefault=false"
            ],
            "ports" => [
                "80:80"
            ],
            "volumes" => [
                "/var/run/docker.sock:/var/run/docker.sock"
            ]
        ];
        $this->assertEquals($expected, $result);
    }

    public function testServiceConfigWithoutLabel(): void
    {
        $generator = new ComposeFileGenerator();
        $config= [
            'image' => 'myimage'
        ];
        $result = $generator->createServiceConfig($config);
        $this->assertEquals([
            'image' => 'myimage'
        ], $result);
    }

    public function testServiceConfigWithVolumes(): void
    {
        $generator = new ComposeFileGenerator();
        $config= [
            'image' => 'myimage',
            'volumes' => [
                'mysql_data' => [
                    'diskSpace' => '1G',
                    'mountPath' => '/var/lib/mysql',
                ]
            ]
        ];
        $result = $generator->createServiceConfig($config);
        $this->assertEquals([
            'image' => 'myimage',
            'volumes' => [
                'mysql_data:/var/www/html',
            ]
        ], $result);
    }

    public function testServiceConfigWithEnvVariables(): void
    {
        $generator = new ComposeFileGenerator();
        $config= [
            'image' => 'myimage',
            'env' => [
                'startup_command' => 'yarn build',
                'dummy_variable' => 'dummy_value'
            ]
        ];
        $result = $generator->createServiceConfig($config);
        $this->assertEquals([
            'image' => 'myimage',
            'environment' => [
                'startup_command' => 'yarn build',
                'dummy_variable' => 'dummy_value'
            ]
        ], $result);
    }

    public function testTraefikLabelsConfig(): void
    {
        $generator = new ComposeFileGenerator();
        $hostConfig = [
            'url' => 'myhost.com'
        ];
        $result = $generator->createTraefikLabels($hostConfig);
        $expected = [
            'traefik.enable=true',
            'traefik.http.routers.front_router.rule=Host(`myhost.com`)'
        ];
        $this->assertEquals($expected, $result);
    }

    public function testTraefikLabelsThrowErrorWhenNoUrl(): void
    {
        $generator = new ComposeFileGenerator();
        $wrongHostConfig = [
            'wrongParameter' => 'myhost.com'
        ];
        $this->expectException(\RuntimeException::class);
        $generator->createTraefikLabels($wrongHostConfig);
    }
    
    public function testCreatedConfigServicesNames(): void
    {
        $generator = new ComposeFileGenerator();
        
        $config = [
            "version" => '1.0',
            "containers" => [
                "php" => [
                    "host" => [
                        'url' => 'myhost.com'
                    ],
                    "image" => "thecodingmachine/php:7.4-v3-apache",
                ],
                "mysql" => [
                    "image" => "mysql"
                ],
                "phpmyadmin" => [
                    "host" => [
                        'url' => 'phpmyadmin.myhost.com'
                    ],
                    "image" => "phpmyadmin",
                    "ports" => [
                        0 => 80
                    ]
                ]

            ]
        ];
        $createdConfig = $generator->createDockerComposeConfig($config);
        $this->assertTrue(isset($createdConfig['services']['traefik']));
        $this->assertTrue(isset($createdConfig['services']['php']));
        $this->assertTrue(isset($createdConfig['services']['mysql']));
        $this->assertTrue(isset($createdConfig['services']['phpmyadmin']));
        
    }

}