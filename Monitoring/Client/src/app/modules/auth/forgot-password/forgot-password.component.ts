import {Component, ViewEncapsulation} from '@angular/core';
import {paths} from '../../../shared/constants';

@Component({
    selector: 'auth-forgot-password',
    templateUrl: './forgot-password.component.html',
    encapsulation: ViewEncapsulation.None
})
export class AuthForgotPasswordComponent {
    paths = paths;

}
