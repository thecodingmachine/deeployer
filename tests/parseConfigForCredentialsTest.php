<?php

namespace App\Tests;

use PHPUnit\Framework\TestCase;
require_once __DIR__.'/../scripts/parseConfigForCredentials.php';

class parseConfigForCredentialsTest extends TestCase
{
    public function testConfigIsparsed(): void
    {
        $returnArray = [];
        foreach (parseConfigForCredentials(__DIR__.'/registryCredentials.json', 'toto') as $command) {
            $returnArray[] = $command;
        }
        
        $expected = [
            "kubectl -n toto delete secret aa827ffc96199a7071140cc2267bc1b1a\n",
            "kubectl -n toto create secret docker-registry aa827ffc96199a7071140cc2267bc1b1a --docker-server=testUrl.com --docker-username=mika --docker-password='secret' --docker-email=mika\n",
            "kubectl -n toto delete secret a7ef8300d82557df5ead6d4576d6388cd\n",
            "kubectl -n toto create secret docker-registry a7ef8300d82557df5ead6d4576d6388cd --docker-server=testUrl2.com --docker-username=mika --docker-password='secret' --docker-email=mika\n",
        ];
        $this->assertEquals($expected, $returnArray);
    }

}