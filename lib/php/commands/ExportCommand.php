<?php


namespace App\commands;


use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class ExportCommand extends Command
{
    protected static $defaultName = 'export';

    protected function configure(): void
    {
        $this->setDescription('Todo the description');
    }

    protected function execute(InputInterface $input, OutputInterface $output)
    {
        return 0;
    }

}