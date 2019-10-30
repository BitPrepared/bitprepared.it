import { Component, Input} from '@angular/core';
import { Indirizzo, Sesso, Social, Reparto, Eg } from './../anagrafica/data-model';

@Component({
  selector: 'app-ui-navbar',
  ng-template: `
    <div id="navbarcontaier">
      <md-toolbar class="navbar">
        <a href="https://precampo.bitprepared.it">Home</a>
        <span class="example-spacer"></span>
        <md-icon class="example-icon" *ngIf="valid">verified_user</md-icon>
      </md-toolbar>
    </div>
  `,
  styleUrls: ['./navbar.component.css']
})
export class NavBarComponent {
  @Input() valid: boolean;

  constructor() {

  }

}
