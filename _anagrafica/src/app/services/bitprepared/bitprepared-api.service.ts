import { Injectable } from '@angular/core';
import { Http, RequestOptions, Headers, Response } from '@angular/http';
import { environment } from '../../../environments/environment';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import 'rxjs/add/operator/catch';

@Injectable()
export class BitPreparedAPIService {

  private username: any;
  private password: string;

  constructor(private http: Http) { }

  login(username, password) {
    this.username = username;
    this.password = password;
  }

  me() {
    const header = new Headers();
    header.append('Authorization', 'Basic  ' + btoa(this.username + ':' + this.password));
    const options = new RequestOptions({ headers: header });
    return this.http.get(environment.bitPreparedUrl + '/me', options)
      .map( (res: Response) => res.json() )
      .catch( (error: any) => {
          return Observable.throw(new Error(error.status));
      });
  }

  update(anagrafica) {
    const header = new Headers();
    header.append('Authorization', 'Basic  ' + btoa(this.username + ':' + this.password));
    header.append('Content-Type', 'application/json');
    const options = new RequestOptions({ headers: header });
    const anagraficaStr = JSON.stringify(anagrafica);
    const anagraficaDue = JSON.parse(anagraficaStr);
    // console.log(anagraficaDue.dtnascita); // 2002-09-18T22:00:00.000Z
    const data = new Date(anagraficaDue.dtnascita);
    anagraficaDue.dtnascita =  this.pad(data.getDate(), 2) + this.pad(data.getMonth() + 1, 2) + String(data.getFullYear());
    return this.http.put(environment.bitPreparedUrl + '/me', JSON.stringify(anagraficaDue), options);
  }

  specialita() {
    const header = new Headers();
    header.append('Authorization', 'Basic  ' + btoa(this.username + ':' + this.password));
    const options = new RequestOptions({ headers: header });
    return this.http.get(environment.bitPreparedUrl + '/specialita', options)
      .map( (res: Response) => res.json() )
      .catch( (error: any) => {
          return Observable.throw(new Error(error.status));
      });
  }

  pad(num: number, size: number): string {
    let s = num + '';
    while (s.length < size) {
      s = '0' + s;
    }
    return s;
  }

}
