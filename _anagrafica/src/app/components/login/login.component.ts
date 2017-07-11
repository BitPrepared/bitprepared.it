import { Component, Input, Output, OnInit, EventEmitter, } from '@angular/core';
import { FormBuilder, FormControl, FormGroup, Validators } from '@angular/forms';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/debounceTime';

@Component({
  selector: 'app-ui-login',
  template: `
    <div>
      <h3>Login</h3>
      <form class="login-form" [formGroup]="loginForm" (ngSubmit)="save(loginForm.value)">
        <md-input-container class="input-full-width">
          <input mdInput formControlName="username" placeholder="username" aria-required="true"
            required=true value="" id="username" name="username">
        </md-input-container>
        <md-input-container class="input-full-width">
          <input mdInput type="password" formControlName="password" placeholder="password" aria-required="true"
            required=true value="" id="password" name="password">
        </md-input-container>
        <button type="submit" md-raised-button>Login</button>
      </form>
    </div>
  `,
  styleUrls: ['./login.component.css']
})
export class LoginComponent {
  @Output() onSubmit: EventEmitter<any> = new EventEmitter();

  loginForm: FormGroup;

  constructor(private fb: FormBuilder) {
    // struttura, qui gli INPUT non sono validi!
    this.loginForm = this.fb.group({
      username: [null, Validators.required ],
      password: [null, Validators.required ],
    });

  }

  save(value: any) {
    if ( this.loginForm.valid ) {
      const credenziali = {
        username: this.loginForm.value['username'],
        password: this.loginForm.value['password'],
      };
      this.onSubmit.emit(credenziali);
    }
  }

}
