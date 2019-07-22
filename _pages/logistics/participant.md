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

L.marker([45.3251557, 8.4227666]).bindPopup("1305780").addTo(map);
L.marker([45.735097, 11.391791]).bindPopup("1336516").addTo(map);
L.marker([45.5501229, 12.0720877]).bindPopup("1380144").addTo(map);
L.marker([45.9308608, 12.4235873]).bindPopup("1281162").addTo(map);
L.marker([43.867643, 10.3397]).bindPopup("1443321").addTo(map);
L.marker([45.6701431, 9.9635127]).bindPopup("1284419").addTo(map);
L.marker([45.4371908, 12.3345898]).bindPopup("1276864").addTo(map);
L.marker([44.5630515, 11.271693]).bindPopup("1418191").addTo(map);
L.marker([44.6458885, 10.9255707]).bindPopup("1315640").addTo(map);
L.marker([45.2417684, 11.7508534]).bindPopup("1309347").addTo(map);
L.marker([44.5993449, 10.6878385]).bindPopup("1354674").addTo(map);
L.marker([44.5993449, 10.6878385]).bindPopup("1354667").addTo(map);
L.marker([40.312527, 18.200425]).bindPopup("1302538").addTo(map);
L.marker([43.7148603, 13.217754]).bindPopup("1441768").addTo(map);
L.marker([43.1607424, 10.6110056]).bindPopup("1289614").addTo(map);
L.marker([40.886431, 17.165495]).bindPopup("1481749").addTo(map);
L.marker([44.4936714, 11.3430347]).bindPopup("1380294").addTo(map);
L.marker([45.6140864, 11.6693937]).bindPopup("1337189").addTo(map);
L.marker([43.1119613, 12.3890104]).bindPopup("1347683").addTo(map);
L.marker([44.8866561, 10.8582083]).bindPopup("1312692").addTo(map);
L.marker([42.420643, 14.28701]).bindPopup("1449835").addTo(map);
L.marker([45.0697151, 7.5176764]).bindPopup("1348451").addTo(map);
L.marker([45.296592, 11.995113]).bindPopup("1358225").addTo(map);
L.marker([44.3535145, 11.7141233]).bindPopup("1445398").addTo(map);
L.marker([44.4161414, 12.2017617]).bindPopup("1450603").addTo(map);
L.marker([43.562561, 13.25007]).bindPopup("1349368").addTo(map);
L.marker([44.9129225, 8.615321]).bindPopup("1365120").addTo(map);
L.marker([41.4672589, 12.9035737]).bindPopup("1369506").addTo(map);
L.marker([45.192498, 11.3111274]).bindPopup("1278068").addTo(map);
L.marker([45.192498, 11.3111274]).bindPopup("1278073").addTo(map);
L.marker([44.4161414, 12.2017617]).bindPopup("1319621").addTo(map);
L.marker([45.9562503, 12.6597197]).bindPopup("1359122").addTo(map);
L.marker([41.894802, 12.4853384]).bindPopup("1353069").addTo(map);
L.marker([44.7835699, 10.8854523]).bindPopup("1282904").addTo(map);
L.marker([44.7835699, 10.8854523]).bindPopup("1320308").addTo(map);
L.marker([41.894802, 12.4853384]).bindPopup("1385884").addTo(map);

</script>
