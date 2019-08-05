<?php
/**
 * Return array of settings
 *
 * @author Stefano Tamagnini <yoghi@sigmalab.net>
 * @license GPLv3
 *
 */
return [
    'settings' => [

        // set to false in production
        'displayErrorDetails' => true,
        
        // Allow the web server to send the content-length header
        'addContentLengthHeader' => false,

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
