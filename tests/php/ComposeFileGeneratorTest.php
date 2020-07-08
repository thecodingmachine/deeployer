<?php


namespace App\Tests;


use App\utils\ComposeFileGenerator;
use PHPUnit\Framework\TestCase;

class ComposeFileGeneratorTest extends TestCase
{
    public function testCreateConfig(): void
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
        $expected = [
            "version" => '1.0',
            "services" => [
                "php" => [
                    "image" => "thecodingmachine/php:7.4-v3-apache",
                    "labels" => [
                        'traefik.enable=true',
                        'traefik.http.routers.front_router.rule=Host(`myhost.com`)'
                    ]
                ],
                "mysql" => [
                    "image" => "mysql"
                ],
                "phpmyadmin" => [
                    "image" => "phpmyadmin",
                    "labels" => [
                        'traefik.enable=true',
                        'traefik.http.routers.front_router.rule=Host(`phpmyadmin.myhost.com`)'
                    ]
                ]
            ]
        ];
        $this->assertEquals($expected, $createdConfig);
        
    }

}