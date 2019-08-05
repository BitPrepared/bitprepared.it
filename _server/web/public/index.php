<?php
date_default_timezone_set('Europe/Rome');

if (PHP_SAPI == 'cli-server') {
    // To help the built-in PHP dev server, check if the request was actually for
    // something which should probably be served as a static file
    $url  = parse_url($_SERVER['REQUEST_URI']);
    $file = __DIR__ . $url['path'];
    if (is_file($file)) {
        return false;
    }
}

require __DIR__ . '/../app/vendor/autoload.php';

session_start();

// Instantiate the app
$settings = include __DIR__ . '/../app/src/settings.php';
$app = new \Slim\App($settings);

// Set up dependencies
require __DIR__ . '/../app/src/dependencies.php';

// Register middleware
require __DIR__ . '/../app/src/middleware.php';

// Register routes
require __DIR__ . '/../app/src/routes.php';

// Run app
$app->run();
