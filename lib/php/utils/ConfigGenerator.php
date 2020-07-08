<?php


namespace App\utils;


class ConfigGenerator
{
    public const schemaFilePath = __DIR__.'/../../../deeployer.schema.json';
    public const tmpFilePath = '/tmp/deeployer.json';

    /**
     * @return mixed[]
     */
    public function getConfig(string $filePath): array
    {
        $tmpFilePath = self::tmpFilePath;
        $env = ""; //todo: get env variables from $ENV ?
        Executor::execute("jsonnet $filePath --ext-code \"env=$env\" --ext-str timestamp=\"2020-05-05 00:00:00\" > $tmpFilePath");
        $schemaFilePath = self::schemaFilePath;
        Executor::execute("ajv test -s $schemaFilePath -d $tmpFilePath --valid");
        
        $content = file_get_contents($tmpFilePath);
        if ($content === false) {
            throw new \RuntimeException("Error when reading $tmpFilePath");
        }
        $json = json_decode($content, true);
        if ($json === false) {
            throw new \RuntimeException('Error when decoding json');
        }
        return $json;
    }

}