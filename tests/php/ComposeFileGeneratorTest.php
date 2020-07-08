<?php


namespace App\Tests;


use App\utils\ComposeFileGenerator;
use PHPUnit\Framework\TestCase;

class ComposeFileGeneratorTest extends TestCase
{
    //todo
    public function testTraefikConfig(): void
    {
        $generator = new ComposeFileGenerator();
        $result = $generator->createTraefikConf();
        $this->assertEquals([], $result);
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
        $createdConfig = $generator->createConfig($config);
        $this->assertTrue(isset($createdConfig['services']['traefik']));
        $this->assertTrue(isset($createdConfig['services']['php']));
        $this->assertTrue(isset($createdConfig['services']['mysql']));
        $this->assertTrue(isset($createdConfig['services']['phpmyadmin']));
        
    }

}