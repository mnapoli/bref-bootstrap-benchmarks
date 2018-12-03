<?php declare(strict_types=1);

use Bref\Application;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Zend\Diactoros\Response\HtmlResponse;

require __DIR__.'/vendor/autoload.php';

$app = new Application;
$app->httpHandler(new class() implements RequestHandlerInterface
{
    public function handle(ServerRequestInterface $request): ResponseInterface
    {
        return new HtmlResponse('Hello world!');
    }
});
$app->run();
