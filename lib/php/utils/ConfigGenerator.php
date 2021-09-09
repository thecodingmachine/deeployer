<?php


namespace App\utils;


use function getenv;

class ConfigGenerator
{
    public const schemaFilePath = __DIR__.'/../../../deeployer.schema.json';
    public const tmpFilePath = '/tmp/deeployer.json';

    /**
     * @return mixed[]
     */
    public function getConfig(string $userConfigFilePath): array
    {
        $tmpJsonFilePath = self::tmpFilePath;
        $env = escapeshellarg('env='.getenv('JSON_ENV'));
        Executor::execute("jsonnet $userConfigFilePath --ext-code $env --ext-str timestamp=\"".date('Y-m-d H:i:s')."\" > $tmpJsonFilePath");
        $schemaFilePath = self::schemaFilePath;
        Executor::execute("ajv test -s $schemaFilePath -d $tmpJsonFilePath --valid -c ajv-formats");

        $content = file_get_contents($tmpJsonFilePath);
        if ($content === false) {
            throw new \RuntimeException("Error when reading $tmpJsonFilePath");
        }
        $json = json_decode($content, true);
        if ($json === false) {
            throw new \RuntimeException('Error when decoding json');
        }
        return $json;
    }

}
