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

<table>
<tr><th>Consulta questa pagina di tanto in tanto per avere aggiornamenti!!</th></tr>
<!--  <tr><th>Citta</th><th>Provincia</th></tr>
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
-->
</table>

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
/*
	L.marker([45.0187717, 11.8119231]).bindPopup("Rachele").addTo(map);
    L.marker([41.8933203, 12.4829321]).bindPopup("Sara, Laura, Hawi").addTo(map);
    L.marker([45.56064035, 8.05324722772595]).bindPopup("Letizia").addTo(map);
    L.marker([43.9098114, 12.9131228]).bindPopup("Margherita, Caterina").addTo(map);
    L.marker([45.4077172, 11.8734455]).bindPopup("Giulia, Pietro").addTo(map);
    L.marker([45.6879136, 10.1837244]).bindPopup("Alessandra").addTo(map);
    L.marker([44.1352264, 12.1998157]).bindPopup("Claudia Marcella").addTo(map);
    L.marker([44.610951, 10.6934336]).bindPopup("Chiara").addTo(map);
    L.marker([45.4741307, 10.8462482]).bindPopup("Rebecca").addTo(map);
    L.marker([45.2337438, 11.8740131]).bindPopup("Marina").addTo(map);
    L.marker([45.9151352, 12.8565956]).bindPopup("Francesca").addTo(map);
    L.marker([44.5769097, 11.3610124]).bindPopup("Edoardo").addTo(map);
    L.marker([41.4672589, 12.9035737]).bindPopup("Walter,Giulio").addTo(map);
    L.marker([44.9261476, 7.9707338]).bindPopup("Samuele").addTo(map);
    L.marker([43.9336213, 10.9174238]).bindPopup("Matteo").addTo(map);
    L.marker([41.1257843, 16.8620293]).bindPopup("Federico").addTo(map);
    L.marker([44.7132091, 11.3065981]).bindPopup("Pietro, Enrico").addTo(map);
    L.marker([45.611508, 9.2750718]).bindPopup("Lorenzo").addTo(map);
    L.marker([45.6452121, 12.1664816]).bindPopup("Sachin").addTo(map);
    L.marker([45.0168524, 11.310498]).bindPopup("Matteo").addTo(map);
    L.marker([45.4667971, 9.1904984]).bindPopup("Pietro").addTo(map);
    L.marker([42.4534556, 14.1409818]).bindPopup("Lorenzo").addTo(map);
*/
</script>
