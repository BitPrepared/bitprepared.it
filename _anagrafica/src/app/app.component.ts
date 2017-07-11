import { Component, OnInit } from '@angular/core';
import { Eg, Reparto, Indirizzo, Social, Sesso, Specialita } from './components/anagrafica/data-model';
import { environment } from '../environments/environment';
import { BitPreparedAPIService } from './services/bitprepared/bitprepared-api.service';
import { MomentModule } from 'angular2-moment';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  title = 'app';
  showEg = false;
  eg: Eg;

  constructor(private hs: BitPreparedAPIService) { }

  ngOnInit() {
    // NOPE
  }

  loadEg(response: any) {
    const eg = new Eg();
    eg.nome = response.nome;
    eg.cognome = response.cognome;
    // tslint:disable-next-line:max-line-length
    eg.dtnascita = new Date(response.dtnascita.substring(4, 8), response.dtnascita.substring(2, 4) - 1, response.dtnascita.substring(0, 2) );
    eg.telefono = response.telefono;
    eg.indirizzo = new Indirizzo();
    eg.indirizzo.cap = response.indirizzo.cap;
    eg.indirizzo.citta = response.indirizzo.citta;
    eg.indirizzo.provincia = response.indirizzo.provincia;
    eg.indirizzo.via = response.indirizzo.via;
    eg.indirizzo.ncivico = response.indirizzo.ncivico;
    eg.social = new Social();
    eg.social.nickname = response.social.nickname;
    eg.social.blog = response.social.blog;
    eg.social.facebook = response.social.facebook;
    eg.social.instagram = response.social.instagram;
    eg.social.email = response.social.email;
    eg.reparto = new Reparto();
    eg.reparto.nomegruppo = response.reparto.nomegruppo;
    eg.reparto.nomereparto = response.reparto.nomereparto;
    eg.reparto.nomesquadriglia = response.reparto.nomesquadriglia;
    eg.reparto.zona = response.reparto.zona;
    this.eg = eg;

    const elencoSpecialitaPossedute = new Array<String>();
    response.specialita.forEach(element => {
      elencoSpecialitaPossedute.push(element.slug);
    });

    this.hs.specialita().subscribe( data => {
      this.eg.specialita = new Array<Specialita>();
      data.forEach(element => {
        const specialita = new Specialita();
        specialita.nome = element.nome;
        specialita.icona = element.icona;
        specialita.slug = element.slug;
        specialita.selected = elencoSpecialitaPossedute.includes(element.slug);
        this.eg.specialita.push(specialita);
      });
      this.showEg = true;
    });
  }

  logError(error: any) {
    console.log(error);
  }

  submit(eg: Eg) {
    this.eg = eg;
    this.hs.update(this.eg).subscribe();
  }

  tryLogin(credenziali) {
    // this.hs.login('Rachele.Grimiti', '19092002');
    this.hs.login(credenziali.username, credenziali.password);
    this.hs.me().subscribe(
      data => this.loadEg(data)
    );
  }

}
