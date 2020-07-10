<?php


namespace App\commands;


use App\utils\ComposeFileGenerator;
use App\utils\ConfigFileFinder;
use App\utils\ConfigGenerator;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class ExportCommand extends Command
{
    protected static $defaultName = 'export';
    /**
     * @var ComposeFileGenerator
     */
    private $composeFileGenerator;
    /**
     * @var ConfigGenerator
     */
    private $configGenerator;
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
        $this->setDescription('Export your config in a docker-compose file');
    }

    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $output->writeln('Exporting your config in docker-compose format...');
        $path = $this->configFileFinder->findFile();
        $config = $this->configGenerator->getConfig($path);
        $dockerComposeConfig = $this->composeFileGenerator->createDockerComposeConfig($config);
        $code = file_put_contents('docker-compose.json', json_encode($dockerComposeConfig, JSON_PRETTY_PRINT));
        if ($code === false) {
            throw new \RuntimeException('Error when creating the docker-compose file.');
        }
        $output->writeln('Done! docker-compose.json was created.');
        return 0;
    }

}