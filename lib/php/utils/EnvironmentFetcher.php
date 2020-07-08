<?php


namespace App\utils;

//not used for now
class EnvironmentFetcher implements EnvironmentFetcherInterface
{
    /**
     * @return string[]
     */
    public function getJSONEnv(): array
    {
        $output = [];
        exec("jq -n env", $output);
        return $output;
    }
}