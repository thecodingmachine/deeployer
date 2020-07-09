<?php


namespace App\commands;


use App\utils\ComposeFileGenerator;
use App\utils\Executor;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class DownCommand extends Command
{
    protected static $defaultName = 'down';

    protected function configure(): void
    {
        $this->setDescription('Todo the description')
            ;
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $message = 'Stopping the containers';
        $tmpFilePath = ComposeFileGenerator::TmpFilePath;
        //todo: should we regenerate the temporary docker-compose file before shutting down the containers?
        $command = "docker-compose -f $tmpFilePath down";
        $output->writeln($message);
        Executor::execute($command);
        return 0;
    }

}