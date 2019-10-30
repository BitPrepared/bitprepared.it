import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MatSnackBarModule, MatIconModule, MatToolbarModule, MatRippleModule, MatCheckboxModule, MatDatepickerModule, MatNativeDateModule, MatGridListModule, MatRadioModule, MatInputModule, MatFormFieldModule, MAT_SNACK_BAR_DEFAULT_OPTIONS } from '@angular/material';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { AppComponent } from './app.component';
import { HttpClientModule }    from '@angular/common/http';
import { AnagraficaComponent } from './components/anagrafica/anagrafica.component';
import { LoginComponent } from './components/login/login.component';
import { NavBarComponent } from './components/navbar/navbar.component';
import { BitPreparedAPIService } from './services/bitprepared/bitprepared-api.service';
import { MomentModule } from 'angular2-moment';

import { HammerGestureConfig, HAMMER_GESTURE_CONFIG } from '@angular/platform-browser';

export class MyHammerConfig extends HammerGestureConfig  {
  overrides = <any>{
       // @see: https://hammerjs.github.io/api/ Constants per avere tutti i valori
       // override default settings
      'swipe': {velocity: 0.4, threshold: 20, direction: 30}
  }
}

@NgModule({
  declarations: [
    AppComponent,
    AnagraficaComponent,
    LoginComponent,
    NavBarComponent
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    FormsModule,
    ReactiveFormsModule,
    MomentModule,
    HttpClientModule,
    MatIconModule,
    MatRippleModule,
    MatDatepickerModule,
    MatNativeDateModule, 
    MatFormFieldModule,
    MatRadioModule,
    MatInputModule,
    MatCheckboxModule,
    MatGridListModule,
    MatToolbarModule,
    MatSnackBarModule
  ],
  providers: [
    {
      provide: HAMMER_GESTURE_CONFIG,
      useClass: MyHammerConfig
    },
    BitPreparedAPIService,
    {
      provide: MAT_SNACK_BAR_DEFAULT_OPTIONS, useValue: {duration: 2500}
    }
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
