<?php


namespace App\Tests;

use App\Tests\mock\MockEnvironmentFetcher;
use App\utils\ConfigGenerator;
use PHPUnit\Framework\TestCase;

class ConfigGeneratorTest extends TestCase
{
    public function testConfigCanGenerate(): void
    {
        $generator = new ConfigGenerator();
        $config = $generator->getConfig(__DIR__.'/json/host.json');
        $expected = [
            "version" => '1.0',
            "containers" => [
                "php" => [
                    "host" => [
                        'url' => 'myhost.com'
                    ],
                    "image" => "thecodingmachine/php:7.4-v3-apache",
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
        $this->assertEquals($expected, $config);
    }    

}