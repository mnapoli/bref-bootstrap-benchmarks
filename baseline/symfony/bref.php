<?php
declare(strict_types=1);

use App\Kernel;
use Bref\Bridge\Symfony\SymfonyAdapter;
use Symfony\Component\Debug\Debug;

ini_set('display_errors', '1');
error_reporting(E_ALL);

require __DIR__.'/vendor/autoload.php';

Debug::enable();

$kernel = new Kernel('prod', false);
$kernel->boot();

$app = new \Bref\Application;
$app->httpHandler(new SymfonyAdapter($kernel));
$app->run();
