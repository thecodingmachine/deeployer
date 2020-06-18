<?php

/**
 * This parse the config to find credentials needed for a named registry
 * This take as parameter the path to the config file and the namespace name
 * This return the list of kubectl commands for bash to execute
 */

$paramPath = $argv[1];
$namespace = $argv[2];
$config = json_decode(file_get_contents($paramPath), true);

if (isset($config['config']['registryCredentials'])) {
    
    foreach ($config['config']['registryCredentials'] as $url => $credentialsData) {
        $slugifiedName = 'a'.md5($url);
        $name = $credentialsData['user'];
        $password = $credentialsData['password'];
        
        echo "kubectl -n $namespace create secret docker-registry $slugifiedName --docker-server=$url --docker-username=$name --docker-password='$password' --docker-email=$name\n";
    }
    
}

