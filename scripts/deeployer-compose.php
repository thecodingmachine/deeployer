<?php

require __DIR__.'/../vendor/autoload.php';

use App\commands\DownCommand;
use App\commands\UpCommand;
use Symfony\Component\Console\Application;

$application = new Application();


$application->add(new UpCommand());
$application->add(new DownCommand());

$application->run();