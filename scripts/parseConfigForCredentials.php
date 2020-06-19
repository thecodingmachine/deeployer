<?php

function parseConfigForCredentials(string $paramPath, string $namespace) {
    $config = json_decode(file_get_contents($paramPath), true);

    if (isset($config['config']['registryCredentials'])) {

        foreach ($config['config']['registryCredentials'] as $url => $credentialsData) {
            $slugifiedName = 'a'.md5($url);
            $name = $credentialsData['user'];
            $password = $credentialsData['password'];

            yield "kubectl -n $namespace create secret docker-registry $slugifiedName --docker-server=$url --docker-username=$name --docker-password='$password' --docker-email=$name\n";
        }

    }
}


