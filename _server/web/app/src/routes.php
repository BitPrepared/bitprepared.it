<?php
// Routes

$app->get('/[{name}]', function ($request, $response, $args) {
    // // Sample log message
    // $this->logger->info("Slim-Skeleton '/' route");

    // // Render index view
    // return $this->renderer->render($response, 'index.phtml', $args);
    return $response->withRedirect('/index.html');
});

$app->get('/api/specialita', function ($request, $response, $args) {
    $attore = new stdClass();
    $attore->nome = 'attore';
    $attore->icona = 'attore';
    $attore->slug = 'attore';
    $fotografo = new stdClass();
    $fotografo->nome = 'fotografo';
    $fotografo->icona = 'fotografo';
    $fotografo->slug = 'fotografo';
    $pioniere = new stdClass();
    $pioniere->nome = 'pioniere';
    $pioniere->icona = 'pioniere';
    $pioniere->slug = 'pioniere';
    $me = [$attore, $fotografo, $pioniere];
    $newResponse = $response->withHeader('Content-type', 'application/json')->withJson($me, 200);

    return $newResponse;
});

$app->put('/api/me', function ($request, $response, $args) {
    $newResponse = $response->withStatus(400);

    $body = $request->getParsedBody();

    $user['id'] = $_SERVER['PHP_AUTH_USER'];
    $user['nome'] = $body['nome'];
    $user['cognome'] = $body['cognome'];
    $user['sesso'] = $body['sesso'];
    $user['dtnascita'] = $body['dtnascita'];
    $user['telefono'] = $body['telefono'];

    $user['nickname'] = $body['social']['nickname'];
    $user['facebook'] = $body['social']['facebook'];
    $user['blog'] = $body['social']['blog'];
    $user['instagram'] = $body['social']['instagram'];
    $user['email'] = $body['social']['email'];

    $user['via'] = $body['indirizzo']['via'];
    $user['ncivico'] = $body['indirizzo']['ncivico'];
    $user['citta'] = $body['indirizzo']['citta'];
    $user['cap'] = $body['indirizzo']['cap'];
    $user['provincia'] = $body['indirizzo']['provincia'];

    $user['zona'] = $body['reparto']['zona'];
    $user['nomegruppo'] = $body['reparto']['nomegruppo'];
    $user['nomereparto'] = $body['reparto']['nomereparto'];
    $user['nomesquadriglia'] = $body['reparto']['nomesquadriglia'];

    $specialitaPossedute = array();
    foreach ($body['specialita'] as $value) {
        if ( $value['selected'] ) {
            $specialitaPossedute[] = $value['nome'];
        }
    }

    $user['specialitaPossedute'] = implode(',',$specialitaPossedute); //'attore,pioniere';

    $sth = $this->dbstore->prepare('UPDATE users SET
          nome = :nome,
          cognome = :cognome,
          sesso   = :sesso,
          dtnascita   = :dtnascita,
          telefono    = :telefono,
          nickname = :nickname,
          facebook    = :facebook,
          blog    = :blog,
          instagram   = :instagram,
          email   = :email,
          via = :via,
          ncivico = :ncivico,
          citta   = :citta,
          cap = :cap,
          provincia   = :provincia,
          zona    = :zona,
          nomegruppo  = :nomegruppo,
          nomereparto = :nomereparto,
          nomesquadriglia = :nomesquadriglia,
          specialita = :specialitaPossedute
          WHERE username = :id');
    try {
        if ($sth->execute($user) && $sth->rowCount()) {
            $newResponse = $response->withStatus(201);
        }
    } catch (PDOException $e) {
        $this->logger->error("db error: {$e->getMessage()}");
    }

    return $newResponse;
});

$app->get('/api/me', function ($request, $response, $args) {
    $auth_username = $_SERVER['PHP_AUTH_USER'];

    $sth = $this->dbstore->prepare('SELECT * from users u where u.username = :username');
    $sth->execute(array(':username' => $auth_username));
    $data = $sth->fetchAll(PDO::FETCH_ASSOC);
    $user = $data[0];

    $me = new stdClass();
    $me->id = $user['username'];
    $me->nome = $user['nome'];
    $me->cognome = $user['cognome'];
    $me->sesso = $user['sesso'];
    $me->dtnascita = $user['dtnascita'];
    $me->telefono = $user['telefono'];

    $social = new stdClass();
    $social->nickname = $user['nickname'];
    $social->facebook = $user['facebook'];
    $social->blog = $user['blog'];
    $social->instagram = $user['instagram'];
    $social->email = $user['email'];
    $me->social = $social;

    $indirizzo = new stdClass();
    $indirizzo->via = $user['via'];
    $indirizzo->ncivico = $user['ncivico'];
    $indirizzo->citta = $user['citta'];
    $indirizzo->cap = $user['cap'];
    $indirizzo->provincia = $user['provincia'];
    $me->indirizzo = $indirizzo;

    $reparto = new stdClass();
    $reparto->zona = $user['zona'];
    $reparto->nomegruppo = $user['nomegruppo'];
    $reparto->nomereparto = $user['nomereparto'];
    $reparto->nomesquadriglia = $user['nomesquadriglia'];
    $me->reparto = $reparto;

    if ( null != $user['specialita'] ){
        $elencoSpecialitaPossedute = explode(',',$user['specialita']); 
        $specialitaPossedute = array();
        foreach ($elencoSpecialitaPossedute as $specialitaNome) {
            $specialita = new stdClass();
            $specialita->nome = $specialitaNome; // superfluo
            $specialita->slug = str_replace(' ','_',$specialitaNome);
            $specialitaPossedute[] = $specialita;;
        }
    } else {
        $specialitaPossedute = [];
    }
    $me->specialita = $specialitaPossedute;

    // Sample log message
    $this->logger->info("API '/api/me' route per utente: {$me->nome} {$me->cognome}");

    $newResponse = $response->withHeader('Content-type', 'application/json')->withJson($me, 200);

    return $newResponse;
});
