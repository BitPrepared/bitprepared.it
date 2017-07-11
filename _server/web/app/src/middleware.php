<?php
// Application middleware

// e.g: $app->add(new \Slim\Csrf\Guard);

use \Slim\Middleware\HttpBasicAuthentication\PdoAuthenticator;

$pdo = new \PDO($settings['settings']['db']);

$container['dbstore'] = function ($c) {
  $db = $c['settings']['dbstore'];
  $pdo = new \PDO($db);
  //$pdo = new PDO("mysql:host=" . $db['host'] . ";dbname=" . $db['dbname'], $db['user'], $db['pass']);
  $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
  $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
  return $pdo;
};

$app->add(new \Slim\Middleware\HttpBasicAuthentication([
    "path" => "/api",
    "realm" => "Protected",
    "authenticator" => new PdoAuthenticator([
        "pdo" => $pdo,
        "table" => "users",
        "user" => "username",
        "hash" => "password"
    ]),
    "error" => function ($request, $response, $arguments) {
        $data = [];
        $data["status"] = "error";
        $data["message"] = $arguments["message"];
        return $response->write(json_encode($data, JSON_UNESCAPED_SLASHES));
    }
]));

$app->add(
  function ($request, $response, $next) {
    $response = $next($request, $response);
    $newResponse = $response->withoutHeader('WWW-Authenticate');
    return $newResponse;
  }
);
