import { Component, Input, Output, OnInit, EventEmitter, } from '@angular/core';
import { FormBuilder, FormControl, FormGroup, Validators } from '@angular/forms';
import { Observable } from 'rxjs';


@Component({
  selector: 'app-ui-login',
  template: `
    <div>
      <h3>Login</h3>
      <form class="login-form" [formGroup]="loginForm" (ngSubmit)="save(loginForm.value)">
        <mat-form-field class="input-full-width">
          <input matInput formControlName="username" placeholder="username" aria-required="true"
            required=true value="" id="username" name="username">
        </mat-form-field>
        <mat-form-field class="input-full-width">
          <input matInput type="password" formControlName="password" placeholder="password" aria-required="true"
            required=true value="" id="password" name="password">
        </mat-form-field>
        <button type="submit" mat-raised-button>Login</button>
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

    // this.loginForm.controls['username'].setValue('Rachele.Grimiti');
    // this.loginForm.controls['password'].setValue('19092002');

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
