import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MaterialModule, MdNativeDateModule } from '@angular/material';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { AppComponent } from './app.component';
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
    MaterialModule,
    MdNativeDateModule,
    FormsModule,
    ReactiveFormsModule,
    HttpModule,
    MomentModule
  ],
  providers: [
    {
      provide: HAMMER_GESTURE_CONFIG,
      useClass: MyHammerConfig
    },
    BitPreparedAPIService
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
