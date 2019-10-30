import { Component, Input} from '@angular/core';
import { Indirizzo, Sesso, Social, Reparto, Eg } from './../anagrafica/data-model';

@Component({
  selector: 'app-ui-navbar',
  template: `
    <div id="navbarcontaier">
      <mat-toolbar class="navbar">
        <a href="https://precampo.bitprepared.it">Home</a>
        <span class="example-spacer"></span>
        <mat-icon class="example-icon" *ngIf="valid">verified_user</mat-icon>
      </mat-toolbar>
    </div>
  `,
  styleUrls: ['./navbar.component.css']
})
export class NavBarComponent {
  @Input() valid: boolean;

  constructor() {

  }

}
