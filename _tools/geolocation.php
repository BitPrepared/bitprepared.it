<?php
require 'vendor/autoload.php';

use GuzzleHttp\Client;

$client = new Client([
    // Base URI is used with relative requests
    'base_uri' => 'http://nominatim.openstreetmap.org/',
    // You can set any number of default request options.
    'timeout'  => 2.0,
]);

function getGeoFromName($client, $name)
{
    $response = $client->request('GET', 'search.php?city='.$name.'&format=json');
    $body = $response->getBody();

    $value = json_decode($body);

    $geo = new stdClass();
    $geo->lat = $value[0]->lat;
    $geo->lon = $value[0]->lon;

    return $geo;
}

$row = 1;
if (($handle = fopen("partecipanti-05-08-2019.csv", "r")) !== false) {
    while (($data = fgetcsv($handle, 1000, ",")) !== false) {
        if ($row > 1) {
            $nome = trim($data[1]);
            $citta = trim($data[3]);
            if ($citta != 'San Mauro in Valle') {
                $geo = getGeoFromName($client, $citta);
            } else {
                $geo = new stdClass();
                $geo->lat = '44.1352264';
                $geo->lon = '12.1998157';
            }
            // echo 'Citta '.$citta.' -> ('.$geo->lat.','.$geo->lon.')'."\n";
            echo 'L.marker(['.$geo->lat.', '.$geo->lon.']).bindPopup("'.$nome.'").addTo(map);'."\n";
        }
        $row++;
    }
    fclose($handle);
}
