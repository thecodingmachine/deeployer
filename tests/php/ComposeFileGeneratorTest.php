<?php


namespace App\Tests;


use App\utils\ComposeFileGenerator;
use PHPUnit\Framework\TestCase;

class ComposeFileGeneratorTest extends TestCase
{
    public function testTraefikConfig(): void
    {
        $generator = new ComposeFileGenerator();
        $config = [
            "version" => '1.0',
            "containers" => [
                "php" => [
                    "host" => [
                        'url' => 'myhost.com',
                    ],
                    "image" => "thecodingmachine/php:7.4-v3-apache",
                ]
            ]
        ];
        $result = $generator->createTraefikConf($config);
        $expected = [
            "image" => "traefik:2.0",
            "command" => [
                "--global.sendAnonymousUsage=false",
                "--log.level=DEBUG",
                "--providers.docker=true",
                "--providers.docker.exposedbydefault=false",
                "--providers.docker.swarmMode=false",
                "--entrypoints.web.address=:80",
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

    public function testTraefikConfigWithHttps(): void
    {
        $generator = new ComposeFileGenerator();
        $config = [
            "version" => '3.3',
            "containers" => [
                "php" => [
                    "host" => [
                        'url' => 'myhost.com',
                        'https' => 'enable'
                    ],
                    "image" => "thecodingmachine/php:7.4-v3-apache",
                ]
            ],
            "config" => [
                "https" => [
                    "mail" => "dt@thecodingmachine.com"
                ]
            ]
        ];
        $expected = [
                    "image" => "traefik:2.0",
                    "command" => [
                        "--global.sendAnonymousUsage=false",
                        "--log.level=DEBUG",
                        "--providers.docker=true",
                        "--providers.docker.exposedbydefault=false",
                        "--providers.docker.swarmMode=false",
                        "--entrypoints.web.address=:80",
                        "--entrypoints.websecured.address=:443",
                        "--certificatesresolvers.letsencrypt.acme.email=dt@thecodingmachine.com",
                        "--certificatesresolvers.letsencrypt.acme.storage=/acme.json",
                        "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web",
                        "--certificatesresolvers.letsencrypt.acme.caServer=https://acme-staging-v02.api.letsencrypt.org/directory"

                    ],
                    "ports" => [
                        "80:80",
                        "443:443"
                    ],
                    "volumes" => [
                        "/var/run/docker.sock:/var/run/docker.sock",
                        "./conf/traefik/acme.json:/acme.json"
                    ]
        ];
        $result = $generator->createTraefikConf($config);
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

    public function testTraefikLabelsConfigWithHttps(): void
    {
        $generator = new ComposeFileGenerator();
        $Config = array (
            'version' => '1.0',
            '$schema' => '../deeployer.schema.json',
            'containers' => 
            array (
              'phpmyadmin' => 
              array (
                'image' => 'phpmyadmin/phpmyadmin',
                'host' => 
                array (
                  'url' => 'myhost.com',
                  'https' => 'true'
                ),
              ),
            ),
          );
        $hostConfig = [
            'url' => 'myhost.com',
            'https' => 'enable'
        ];
        $result = $generator->createTraefikLabels($hostConfig, 'phpmyadmin');
        $expected = [
            "traefik.enable=true",
            "traefik.http.routers.phpmyadmin.rule=Host(`myhost.com`)",
            "traefik.http.routers.phpmyadmin.entrypoints=websecured"
        ];
        $this->assertEquals($expected, $result);
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
        $result = $generator->createTraefikLabels($hostConfig, 'mysql');
        $expected = [
            'traefik.enable=true',
            'traefik.http.routers.mysql.rule=Host(`myhost.com`)'
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
                        'url' => 'myhost.com',
                        'https' => 'true'
                    ],
                    "image" => "thecodingmachine/php:7.4-v3-apache",
                ],
                "mysql" => [
                    "image" => "mysql:5.8"
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

                    ],
            "config" => [
                "https" => [
                    "mail" => "m.diallo@thecodingmachine.com"
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
        $this->assertSame('traefik.enable=true', $createdConfig['services']['php']['labels'][0]);
        $this->assertSame('traefik.http.routers.php.rule=Host(`myhost.com`)', $createdConfig['services']['php']['labels'][1]);
    }

    public function testThereIsNoTraefikIfThereIsNoHost(): void
    {
        $generator = new ComposeFileGenerator();

        $config = [
            "version" => '3.3',
            "containers" => [
                "mysql" => [
                    "image" => "mysql",
                ]
            ]
        ];
        $createdConfig = $generator->createDockerComposeConfig($config);
        $this->assertArrayNotHasKey('traefik', $createdConfig['services']);
    }


    public function testVolumesCreated(): void
    {
        $generator = new ComposeFileGenerator();

        $config = [
            "version" => '1.0',
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
        $this->assertEquals("local", $createdConfig['volumes']['mysqldata']['driver']);
        $this->assertEquals(["mysqldata:/var/lib/mysql"], $createdConfig['services']['mysql']['volumes']);
    }
}