<?php

require_once 'runParseConfigForCredentials.php';

/**
 * This parse the config to find credentials needed for a named registry
 * This take as parameter the path to the config file and the namespace name
 * This return the list of kubectl commands for bash to execute
 */

$paramPath = $argv[1];
$namespace = $argv[2];

foreach (parseConfigForCredentials($paramPath, $namespace) as $command) {
    echo $command;
}