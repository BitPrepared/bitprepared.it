export enum Sesso {M, F}

export class Eg {
  id = 0;
  nome = '';
  cognome = '';
  sesso: Sesso = Sesso.M;
  dtnascita: Date;
  telefono: number;
  indirizzo: Indirizzo;
  social: Social;
  reparto: Reparto;
}

export class Indirizzo {
  via = '';
  ncivico: number;
  citta   = '';
  cap    = '';
  provincia    = '';
}

export class Social {
  nickname = '';
  facebook = '';
  blog = '';
  instagram = '';
  email = '';
}

export class Reparto {
  zona = '';
  nomegruppo = '';
  nomereparto = '';
  nomesquadriglia = '';
}

export const specialitaEsistenti = ['Prima', 'Seconda', 'Terza', 'Quarta'];
