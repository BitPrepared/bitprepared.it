---
layout: page
permalink: /participant/
title: Participant
tags: [bitprepared, participant]
modified: 2017-07-10
image:
  feature: logistics/participant.png 
  credit: BitPrepared
  creditlink: https://bitprepared.it
---
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.1.0/dist/leaflet.css" integrity="sha512-wcw6ts8Anuw10Mzh9Ytw4pylW8+NAD4ch3lqm9lzAsTxg0GFeJgoAtxuCLREZSC5lUXdVyo/7yfsqFjQ4S+aKw==" crossorigin=""/>

<script src="https://unpkg.com/leaflet@1.1.0/dist/leaflet.js" integrity="sha512-mNqn2Wg7tSToJhvHcqfzLMU6J4mkOImSPTxVZAdo+lcPlk+GhZmYgACEe0x35K7YzW1zJ7XyJV/TT1MrdXvMcA==" crossorigin=""></script>

<h2>Provenienze dei partecipanti</h2>

<p>Per venire incontro a chi deve intraprendere il viaggio di andata e di ritorno da solo, 
di seguito elenchiamo le provenienze dei vari Esploratori e Guide, seguito dal numero di scout.
</p>

<p>Se pensate ci possa essere qualcuno con cui accordarvi, scrivete ai Capi Campo che vi daranno il numero telefonico per mettervi in contatto
</p>

<div id='map'></div>

<br/>
<!--
<table>
<tr><th>Consulta questa pagina di tanto in tanto per avere aggiornamenti!!</th></tr>
<tr><th>Citta</th><th>Provincia</th></tr>
  <tr><td>Pontecchio Polesine</td><td>Rovigo</td></tr>
  <tr><td>Roma</td><td>	Roma</td></tr>
  <tr><td>Roma</td><td>	Roma</td></tr>
  <tr><td>Biella</td><td>	Biella</td></tr>
  <tr><td>Pesaro</td><td>	Pesaro-Urbino</td></tr>
  <tr><td>Pesaro</td><td>	Pesaro-Urbino</td></tr>
  <tr><td>Roma</td><td>	Roma</td></tr>
  <tr><td>Padova</td><td>	Padova</td></tr>
  <tr><td>Gardone Val Trompia	</td><td> Brescia</td></tr>
  <tr><td>San Mauro in Valle</td><td>Forlì-Cesena</td></tr>
  <tr><td>Fellegara</td><td>	Reggio Emilia</td></tr>
  <tr><td>Bussolengo</td><td>	Verona</td></tr>
  <tr><td>Conselve</td><td>	Padova</td></tr>
  <tr><td>San Vito al Tagliamente</td><td>	Pordenone</td></tr>
  <tr><td>Castel Maggiore</td><td>	Bologna</td></tr>
  <tr><td>Latina</td><td>	Latina</td></tr>
  <tr><td>Dusino San Michele</td><td> Asti</td></tr>
  <tr><td>Pistoia</td><td>	Pistoia</td></tr>
  <tr><td>Bari</td><td>	Bari</td></tr>
  <tr><td>Padova</td><td>	Padova</td></tr>
  <tr><td>Pieve di Cento</td><td>	Bologna</td></tr>
  <tr><td>Pieve di Cento</td><td>	Bologna</td></tr>
  <tr><td>Vedano al Lambro</td><td>	Monza-Brianza</td></tr>
  <tr><td>Quinto di Treviso</td><td>	Treviso</td></tr>
  <tr><td>Castelmassa</td><td>	Rovigo</td></tr>
  <tr><td>Latina</td><td>	Latina</td></tr>
  <tr><td>Milano</td><td>	Milano</td></tr>
  <tr><td>Spoltore</td><td>	Pescara</td></tr>
</table>
-->

<script>
	var map = L.map('map').setView([44, 12], 6);
  map.locate({setView: true, maxZoom: 6});

	L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
		attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
	}).addTo(map);

  function onLocationFound(e) {
    var radius = e.accuracy / 2;

    L.marker(e.latlng).addTo(map)
     .bindPopup("You are within " + radius + " meters from this point").openPopup();

    L.circle(e.latlng, radius).addTo(map);
  }

  map.on('locationfound', onLocationFound);

  L.marker([45.0697151, 7.5176764]).bindPopup("vittoria").addTo(map);
  L.marker([40.7376788, 14.5722442]).bindPopup("beatrice").addTo(map);
  L.marker([43.7629956, 10.4410399]).bindPopup("sofia").addTo(map);
  L.marker([44.4760177, 11.2756857]).bindPopup("olivia").addTo(map);
  L.marker([45.7113511, 11.3553593]).bindPopup("beatrice").addTo(map);
  L.marker([44.5255217, 10.8663607]).bindPopup("anna").addTo(map);
  L.marker([45.1346168, 10.0251103]).bindPopup("carlotta").addTo(map);
  L.marker([45.9145042, 12.8565956]).bindPopup("bianca").addTo(map);
  L.marker([45.5139771, 11.1656408]).bindPopup("beatrice").addTo(map);
  L.marker([45.735097, 11.391791]).bindPopup("giulia").addTo(map);
  L.marker([45.1346168, 10.0251103]).bindPopup("chiara").addTo(map);
  L.marker([43.3113449, 10.5173443]).bindPopup("maria").addTo(map);
  L.marker([45.0677551, 7.6824892]).bindPopup("marta").addTo(map);
  L.marker([44.40726, 8.9338624]).bindPopup("lara").addTo(map);
  L.marker([45.9562503, 12.6597197]).bindPopup("marco").addTo(map);
  L.marker([46.0664228, 11.1257601]).bindPopup("pietro").addTo(map);
  L.marker([45.6628395, 11.8284875]).bindPopup("tommaso").addTo(map);
  L.marker([45.0534751, 9.6947461]).bindPopup("carlo").addTo(map);
  L.marker([40.7376788, 14.5722442]).bindPopup("massimiliano").addTo(map);
  L.marker([44.900542, 8.2068876]).bindPopup("enrico").addTo(map);
  L.marker([44.2226017, 12.0409384]).bindPopup("marcello").addTo(map);
  L.marker([45.5846274, 10.438237]).bindPopup("massimiliano").addTo(map);
  L.marker([45.218894, 12.2785805]).bindPopup("luca").addTo(map);
  L.marker([43.7148603, 13.217754]).bindPopup("alessandro").addTo(map);
  L.marker([46.1605087, 12.6621363]).bindPopup("davidegiovanni").addTo(map);
  L.marker([45.10955285, 10.7158422823227]).bindPopup("lorenzo").addTo(map);

</script>
