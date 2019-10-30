<?php

date_default_timezone_set('Europe/Rome');

$row = 1;
if (($handle = fopen("partecipanti-05-08-2019.csv", "r")) !== false) {
    while (($data = fgetcsv($handle, 1000, ",")) !== false) {
        if ($row > 1) {
            $nome = trim(str_replace(' ', '', $data[1]));
            $cognome = trim(str_replace(' ', '', $data[2]));
            $dtnascita = DateTime::createFromFormat('dmY', trim($data[5])); //19/09/02
            $dtnascitastr = $dtnascita->format('dmY');
            $citta = trim($data[3]);
            $provincia = trim($data[4]);

            $username = strtolower($nome.'.'.$cognome);
            $hash = password_hash($dtnascitastr, PASSWORD_DEFAULT);

            $query = "INSERT INTO users (nome, cognome, dtnascita, citta, provincia, username, password) VALUES ('{$nome}', '{$cognome}', '{$dtnascitastr}', '{$citta}', '{$provincia}', '{$username}', '{$hash}')";
            echo $query.";\n";
            //$status = $pdo->exec($query);
        }
        $row++;
    }
    fclose($handle);
}
