<?php

namespace App\utils;

interface EnvironmentFetcherInterface
{
    /**
     * @return string[] 
     */
    public function getJSONEnv(): array;
}