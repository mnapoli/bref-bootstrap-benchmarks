This is a benchmark of possible solutions for Bref to run PHP on AWS Lambda.

The issue in Bref is here: [mnapoli/bref#100](https://github.com/mnapoli/bref/issues/100).

I will use Symfony in the examples just for illustration but this applies to all frameworks. **Jump at the end for the numbers.**

## Solutions

### Solution A

We run the PHP code in the same process as `bootstrap`, very similarly to what can be done with ReactPHP/Amp/Aerys/Swoole...

This is very fast, both for cold starts and warm requests! We can get response times below 10ms with that. However, just like when using such frameworks outside of lambda we have disadvantages: **the memory is shared between all requests**. That means we can have memory leaks, we have to be careful about global state, etc. Also a fatal error will kill the whole lambda (a new lambda will be started by AWS but that means a new cold start).

This is a very interesting option that can be worth proposing as an option, but it cannot be the default solution that will work with all apps/frameworks.

<details><summary>Click here for code examples</summary>

Example of a `bootstrap`:

```php
<?php
// ...
require __DIR__ . '/vendor/autoload.php';

// BOOT Symfony BEFORE a request comes in!
$kernel = new Kernel('prod', false);
$kernel->boot();
$symfonyAdapter = new SymfonyAdapter($kernel);

while (true) {
    $event = waitForEventFromLambdaApi(); // This is a blocking HTTP call until an event is available

    $request = RequestFactory::fromLambdaEvent($event);
    // REUSE the same Symfony Kernel, meaning fast response time!
    $response = $symfonyAdapter->handle($request);
    $lambdaResponse = LambdaResponse::fromPsr7Response($response);

    signalSuccessToLambdaApi($lambdaResponse);
}
```

</details>

### Solution B

The `bootstrap` starts a sub-process (`exec`) every time an event needs to be processed.

That allows to protect the `bootstrap` process from failures of the children. This is basically what Bref does at the moment.

This is similar too to how PHP-FPM works (in the spirit at least).

<details><summary>Click here for code examples</summary>

Example of a `bootstrap`:

```php
<?php
// ...
while (true) {
    $event = waitForEventFromLambdaApi(); // This is a blocking HTTP call until an event is available

    $process = new Process(['/opt/bin/php', 'index.php', /* pass the event as an argument */]);
    $process->run(); // This waits for the process to finish

    // [fetch response ...]

    signalSuccessToLambdaApi($lambdaResponse);
}
```

Example of a `index.php` that could be executed by that:

```php
<?php
// ...
require __DIR__ . '/vendor/autoload.php';

// [fetch event from process args]

$kernel = new Kernel('prod', false);
$kernel->boot();
$symfonyAdapter = new SymfonyAdapter($kernel);
$request = RequestFactory::fromLambdaEvent($event);
$response = $symfonyAdapter->handle($request);
$lambdaResponse = LambdaResponse::fromPsr7Response($response);

// [return response to bootstrap somehow]

exit(0); // DIE!
```

</details>

### Solution C

Just like *B* except `bootstrap` does not handle events: it immediately executes a sub-process. The PHP sub-process will call the integration HTTP API *and wait for an event*. That means that we can run code **before** waiting for an event. E.g. we can bootstrap Composer's autoloader and Symfony before a request comes in!

<details><summary>Click here for code examples</summary>

Example of a `bootstrap`:

```php
<?php
// ...
while (true) {
    $process = new Process(['/opt/bin/php', 'index.php']);
    $process->run(); // This waits for the process to finish (i.e. waits until an event has been processed)
}
```

Example of a `index.php` that could be executed by that:

```php
<?php
// ...
require __DIR__ . '/vendor/autoload.php';

// BOOT Symfony BEFORE a request comes in!
$kernel = new Kernel('prod', false);
$kernel->boot();
$symfonyAdapter = new SymfonyAdapter($kernel);

$event = waitForEventFromLambdaApi(); // This is a blocking HTTP call until an event is available

$request = RequestFactory::fromLambdaEvent($event);
$response = $symfonyAdapter->handle($request);
$lambdaResponse = LambdaResponse::fromPsr7Response($response);

signalSuccessToLambdaApi($lambdaResponse);

exit(0); // DIE!
```

</details>

### Solution D

How about instead of creating a new process we fork the `bootstrap` process? The app would bootstrap once in total, but still **there is no shared state between events** (because each event is processed by a fork).

<details><summary>Click here for code examples</summary>

Example of `bootstrap`:

```php
<?php
// ...
require __DIR__ . '/vendor/autoload.php';
// BOOT Symfony ONLY ONCE for all the requests!
$kernel = new Kernel('prod', false);
$kernel->boot();
$symfonyAdapter = new SymfonyAdapter($kernel);

while (true) {
    $pid = pcntl_fork();
    if ($pid) { // Root process
        pcntl_wait($status); // Wait for the child to process the event
    } else {    // Child process
        // Here the autoloader is already loaded and Symfony initialized!
        $event = waitForEventFromLambdaApi(); // This is a blocking HTTP call until an event is available

        $request = RequestFactory::fromLambdaEvent($event);
        $response = $symfonyAdapter->handle($request);
        $lambdaResponse = LambdaResponse::fromPsr7Response($response);

        signalSuccessToLambdaApi($lambdaResponse);

        exit(0); // The fork DIES! The root process will resume its execution and loop
    }
}
```

</details>

### Solution E

Solution E is about starting PHP-CGI/PHP-FPM and run it with only one PHP worker. The `bootstrap` would be responsible for forwarding Lambda events using the FastCGI protocol.

### Solution F

Solution F is about starting the PHP built-in webserver. The `bootstrap` would be responsible for forwarding Lambda events to the webserver via HTTP.

### Solution G

Solution G is about writing a custom PHP SAPI (in C) that is inspired from PHP-FPM and the built-in webserver. This SAPI is run by `bootstrap` and executes a PHP script in a loop, but resets the memory on every loop.

The PHP script would wait for the event, receive it, process it and send a response. The custom SAPI resets the memory every time.

This is basically like solution A except the memory is reset on every loop, meaning we keep the request isolation that exists in PHP since its beginning. It would also be better than solution B/C because by running everything in a single PHP process we avoid the overhead of booting a process for every event.

### Solution H

Solution H is like solution C except it uses PHP CGI instead of PHP CLI. The `bootstrap` would be responsible for executing `php-cgi` on every event/request and forward the event data via the CGI protocol.

## Results

Those are Lambda execution time (not HTTP response time because you would have to account API Gateway).

| Solution | Framework | Average | Minimum | URL |
|----------|-----------|---------|---------|-----|
| LAMP stack | PHP | 1ms | 0ms |  |
| LAMP stack | Symfony | 6ms | 4ms |  |
| Bref 0.2 (baseline) | PHP | 23ms | 15ms | [url](https://69sgjkx4e0.execute-api.us-east-2.amazonaws.com/dev) |
| Bref 0.2 (baseline) | Symfony | 50ms | 26ms | [url](https://kvverflq1a.execute-api.us-east-2.amazonaws.com/dev) |
| A | PHP | 5ms | 1ms | [url](https://d8ua4jrr82.execute-api.us-east-2.amazonaws.com/Prod) |
| A | Symfony | 6ms | 3ms | [url](https://uvrof4qhjb.execute-api.us-east-2.amazonaws.com/Prod) |
| B |  |  |  |  |
| C | PHP |  |  | bugged - please help :) |
| C | Symfony | 81ms | 65ms | [url](https://x9xirvj7a5.execute-api.us-east-2.amazonaws.com/Prod) |
| D | PHP | 12ms | 6ms | [url](https://27nex4iys7.execute-api.us-east-2.amazonaws.com/Prod) |
| D | Symfony | 26ms | 15ms | [url](https://elha5ztbse.execute-api.us-east-2.amazonaws.com/Prod) |
| E | PHP | 5ms | 1.1ms |  |
| E | Symfony | 25ms | 13ms |  |
| F | PHP | 5ms | 1.6ms |  |
| F | Symfony | 24ms | 16ms |  |
| G | PHP | 10ms | 6ms | [url](https://52ndy2s1ah.execute-api.us-east-2.amazonaws.com/Prod) |
| G | Symfony | 7ms | 3ms | [url](https://g9fzxul00f.execute-api.us-east-2.amazonaws.com/Prod) |
| H | PHP | ? | ? |  |
| H | Symfony | 45ms | 22ms |  |

The LAMP stack is a baseline of running the same code but on a classic server with Apache or Nginx. This will help compare performances between LAMP and PHP on Lambda.

## How to run

- clone the repository
- `make install`
- go into a subdirectory and run `make preview` to test it locally (you'll need to install AWS SAM, the lambda will run in Docker automatically, try it out it's magic!)
- run `make deploy` in a subdirectory to deploy that lambda

To deploy you will need to create a bucket and update the bucket name everywhere in the scripts. I also used the `us-east-2` region because I don't have anything in that region so it's easy to delete everything afterwards. If you want to let that be configured by an env variable or some other config file send a pull request!

To benchmark: run `ab -c 1 -n 100 <the url of the lambda>` (check the URL responds correctly). Check out the execution time *of the lambda* in Cloudwatch.

The first time you deploy, if it fails, you will need to delete the stack in CloudFormation manually. This is how CloudFormation works.
