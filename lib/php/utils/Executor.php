<?php


namespace App\utils;

class Executor
{
    public static function execute(string $command): void
    {
        $returnCode = null;
        passthru($command, $returnCode);
        if ($returnCode !== 0) {
            throw new \RuntimeException("Error when executing the command $command");
        }
    }
}