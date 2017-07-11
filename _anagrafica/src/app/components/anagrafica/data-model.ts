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
  specialita: Specialita[];
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

export class Specialita {
  nome = '';
  icona = '';
  slug = '';
  selected = false;
}
