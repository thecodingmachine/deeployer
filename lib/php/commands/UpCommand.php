<?php


namespace App\commands;


use App\utils\ComposeFileGenerator;
use App\utils\ConfigFileFinder;
use App\utils\ConfigGenerator;
use App\utils\Executor;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

class UpCommand extends Command
{
    protected static $defaultName = 'up';
    /**
     * @var ConfigGenerator
     */
    private $configGenerator;
    /**
     * @var ComposeFileGenerator
     */
    private $composeFileGenerator;
    /**
     * @var ConfigFileFinder
     */
    private $configFileFinder;

    public function __construct(string $name = null)
    {
        parent::__construct($name);
        $this->configFileFinder = new ConfigFileFinder();
        $this->configGenerator = new ConfigGenerator();
        $this->composeFileGenerator = new ComposeFileGenerator();
    }

    protected function configure(): void
    {
        $this->setDescription('Todo the description')
            ->addOption(
                'detach',
                'd',
                InputOption::VALUE_NONE,
                'Run the command in detach mode'
            );
    }

    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $path = $this->configFileFinder->findFile();
        $config = $this->configGenerator->getConfig($path);
        $filePath = $this->composeFileGenerator->createFile($config);
        
        $detachMode = (bool) $input->getOption('detach');
        
        $message = 'Starting the containers';
        $comand = "docker-compose -f $filePath up";
        if ($detachMode) {
            $message .= ' in detached mode';
            $comand .= ' -d';
        }
        $output->writeln($message);
        Executor::execute($comand);
        return 0;

    }

}