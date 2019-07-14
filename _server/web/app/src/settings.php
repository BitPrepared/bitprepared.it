<?php
return [
    'settings' => [
        'displayErrorDetails' => true, // set to false in production
        'addContentLengthHeader' => false, // Allow the web server to send the content-length header

        // Renderer settings
        'renderer' => [
            'template_path' => __DIR__ . '/../templates/',
        ],

        // Monolog settings
        'logger' => [
            'name' => 'slim-app',
            'path' => __DIR__ . '/../logs/app.log',
            'level' => \Monolog\Logger::DEBUG,
        ],

        // database
        //'db' => 'sqlite:'.__DIR__.'/../users.sqlite',
        //'dbstore' => 'sqlite:'.__DIR__.'/../users.sqlite',
        'dbstore' => 'mysql:host=localhost;dbname=precampo2019;charset=utf8'
    ],
];
