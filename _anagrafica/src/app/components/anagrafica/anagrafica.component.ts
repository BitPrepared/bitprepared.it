import { Component, Input, Output, OnInit, EventEmitter, } from '@angular/core';
import { FormBuilder, FormControl, FormGroup, FormArray, Validators } from '@angular/forms';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/debounceTime';
import { Indirizzo, Sesso, Social, Reparto, Eg, Specialita } from './data-model';
import { MdCheckbox, MdCheckboxChange, MdCheckboxModule } from '@angular/material';

const EMAIL_REGEX = /^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/;

@Component({
  selector: 'app-ui-anagrafica',
  templateUrl: './anagrafica.component.html',
  styleUrls: ['./anagrafica.component.css']
})
export class AnagraficaComponent implements OnInit {
  @Input() eg: Eg;
  @Output() onValidSubmit: EventEmitter<Eg> = new EventEmitter();


  invalidFieldSex = false;
  egForm: FormGroup;
  submitted = false;
  minDate = new Date(2001, 0, 1);
  maxDate = new Date(2003, 11, 31);

  constructor(private fb: FormBuilder) {
    // struttura, qui gli INPUT non sono validi!
    this.egForm = this.fb.group({
      nome: [null, Validators.required ],
      cognome: [null, Validators.required ],
      sesso: [null, Validators.required ],
      dtnascita: [null, Validators.required ],
      telefono: [null, [Validators.required, Validators.pattern('[0-9]{5,15}')] ],
      specialita: null,
      indirizzo: this.fb.group({ // <-- the child FormGroup
        via: [null, Validators.required ],
        ncivico: [null, Validators.required],
        citta: [null, Validators.required ],
        cap: [null, [Validators.pattern('[0-9]{5}')]],
        provincia: null,
        email: null
      }) ,
      social: this.fb.group({
        nickname: null,
        facebook: null,
        instagram: null,
        blog: null,
        email: [null, Validators.pattern(EMAIL_REGEX)]
      }),
      reparto: this.fb.group({
        nomereparto: null,
        nomesquadriglia: null,
        nomegruppo: null,
        zona: null
      })
    });

    this.egForm.valueChanges.debounceTime(3000).subscribe(val => {
      this.mapNewValue(val);
    });
  }

  mapNewValue(val: any) {
    this.eg.nome = val.nome;
    this.eg.cognome = val.cognome;
    this.checkSexValidity();
    if ( !this.invalidFieldSex ) {
      this.eg.sesso = val.sesso;
    }
    this.eg.dtnascita = val.dtnascita;
    const x: number = Number(val.telefono);
    this.eg.telefono = x;
    this.eg.indirizzo = this.mapIndirizzo(val.indirizzo);
    this.eg.social = this.mapSocial(val.social);
    this.eg.reparto = this.mapReparto(val.reparto);
  }

  changeSpecialitaPosseduta(event: MdCheckboxChange, i: number) {
    this.eg.specialita[i].selected = event.checked;
  }

  mapSocial(social: any): Social {
    const result = new Social();
    result.nickname = social.nickname;
    result.facebook = social.facebook;
    result.blog = social.blog;
    result.email = social.email;
    return result;
  }

  mapIndirizzo(indirizzo: any): Indirizzo {
    const result = new Indirizzo();
    result.via = indirizzo.via;
    result.ncivico = indirizzo.ncivico;
    result.citta = indirizzo.citta;
    result.provincia = indirizzo.provincia;
    result.cap = indirizzo.cap;
    return result;
  }

  mapReparto(reparto: any): Reparto {
    const result = new Reparto();
    result.zona = reparto.zona;
    result.nomereparto = reparto.nomereparto;
    result.nomesquadriglia = reparto.nomesquadriglia;
    result.nomegruppo = reparto.nomegruppo;
    return result;
  }

  checkSexValidity() {
    if ( this.egForm.controls['sesso'].hasError('required') && this.submitted ) {
      this.invalidFieldSex = true;
    } else {
      this.invalidFieldSex = false;
    }
  }

  ngOnInit() {
    this.egForm.patchValue({
      nome: this.eg.nome,
      cognome: this.eg.cognome,
      sesso: Sesso[this.eg.sesso],
      telefono: this.eg.telefono,
      dtnascita: this.eg.dtnascita,
      indirizzo: this.eg.indirizzo || new Indirizzo(),
      social: this.eg.social || new Social(),
      reparto: this.eg.reparto || new Reparto()
    });
    // specialita essendo fuori dal form control posso farlo direttamente in html
  }

  save(value: any) {
    this.submitted = true;
    this.checkSexValidity();
    if ( this.egForm.valid ) {
      this.mapNewValue(this.egForm.value);
      this.onValidSubmit.emit(this.eg);
    }
  }

}
