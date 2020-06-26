<?php


namespace App\commands;


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
        $command = 'docker-compose down';
        $output->writeln($message);
        Executor::execute($command);
        return 0;
    }

}