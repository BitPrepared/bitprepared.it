
import {throwError as observableThrowError,  Observable } from 'rxjs';
import { Injectable } from '@angular/core';
import { environment } from '../../../environments/environment';
import { HttpClient, HttpHeaders, HttpResponse } from '@angular/common/http';
import { map, catchError } from 'rxjs/operators';


@Injectable()
export class BitPreparedAPIService {

  private username: any;
  private password: string;

  constructor(private http: HttpClient) { }

  login(username, password) {
    this.username = username;
    this.password = password;
  }

  me() : Observable<HttpResponse<any>> {
    const headers = new HttpHeaders();
    headers.set('Authorization', 'Basic  ' + btoa(this.username + ':' + this.password));
    return this.http.get<any>(environment.bitPreparedUrl + '/me', { headers });
      // .pipe(
      //   map( (res: Response) => res.json() ),
      //   catchError( (error: any) => {
      //     return observableThrowError(new Error(error.status));
      //   })
      // );
  }

  update(anagrafica) {
    const headers = new HttpHeaders();
    headers.set('Authorization', 'Basic  ' + btoa(this.username + ':' + this.password));
    headers.set('Content-Type', 'application/json');
    const anagraficaStr = JSON.stringify(anagrafica);
    const anagraficaDue = JSON.parse(anagraficaStr);
    // console.log(anagraficaDue.dtnascita); // 2002-09-18T22:00:00.000Z
    const data = new Date(anagraficaDue.dtnascita);
    anagraficaDue.dtnascita =  this.pad(data.getDate(), 2) + this.pad(data.getMonth() + 1, 2) + String(data.getFullYear());
    return this.http.put(environment.bitPreparedUrl + '/me', JSON.stringify(anagraficaDue), { headers });
  }

  specialita() : Observable<HttpResponse<any>> {
    const headers = new HttpHeaders();
    headers.set('Authorization', 'Basic  ' + btoa(this.username + ':' + this.password));
    return this.http.get<any>(environment.bitPreparedUrl + '/specialita', { headers });
    // .pipe(
    //     map( (res: Response) => res.json() ),
    //     catchError( (error: any) => {
    //       return observableThrowError(new Error(error.status));
    //     })
    //   );
  }

  pad(num: number, size: number): string {
    let s = num + '';
    while (s.length < size) {
      s = '0' + s;
    }
    return s;
  }

}
