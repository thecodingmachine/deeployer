<?php


namespace App\utils;


class ConfigFileFinder
{
    public const VALUE_1 = './deeployer.libsonnet';
    public const VALUE_2 = './deeployer.json';
    
    /**
     * This search for an appropriate jsonnet config file and return its path
     */
    public function findFile(): string
    {
        if (file_exists(self::VALUE_1)) {
            return self::VALUE_1;
        }
        if (file_exists(self::VALUE_2)) {
            return self::VALUE_2;
        }
        throw new \RuntimeException('No deeployer config file was found.');
    }

}