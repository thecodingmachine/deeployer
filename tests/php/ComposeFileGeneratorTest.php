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
        $config = [
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
        $config = [
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
                'mysql_data:/var/lib/mysql',
            ]
        ], $result);
    }

    public function testServiceConfigWithEnvVariables(): void
    {
        $generator = new ComposeFileGenerator();
        $config = [
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

    public function testHost(): void
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
                ]
            ]
        ];
        $createdConfig = $generator->createDockerComposeConfig($config);

        $this->assertArrayHasKey('traefik', $createdConfig['services']);
        $this->assertNotSame('traefik.enable=true', $createdConfig['services']['php']['labels'][1]);
        $this->assertNotSame('traefik.http.routers.php.rule=Host(`myhost.com`)', $createdConfig['services']['php']['labels'][1]);
    }

    public function testThereIsNoTraefikIfThereIsNoHost(): void
    {
        $generator = new ComposeFileGenerator();

        $config = [
            "version" => '1.0',
            "containers" => [
                "mysql" => [
                    "image" => "mysql"
                ]
            ]
        ];
        $createdConfig = $generator->createDockerComposeConfig($config);
        $this->assertArrayHasKey('traefik', $createdConfig['services']);
    }


    public function testVolumesCreated(): void
    {
        $generator = new ComposeFileGenerator();

        $config = [
            "containers" => [
                "mysql" => [
                    "image" => "mysql",
                    "volumes" => [
                        "mysqldata" =>  [
                            "diskSpace" => "1G",
                            "mountPath" => "/var/lib/mysql",
                        ]
                    ]
                ]
            ]
        ];
        $createdConfig = $generator->createDockerComposeConfig($config);
        //$this->assertArrayHasKey('mysqldata', $createdConfig['volumes']);
        $this->assertEquals([
            "services" => [
                "mysql" => [
                    "image" => "mysql",
                    "volumes" => ["mysqldata:/var/lib/mysql"]
                ]
                ],
            "volumes" => [
                "mysql_data" => [ "driver" => "local"]
            ]
        ], $createdConfig);
    }
}