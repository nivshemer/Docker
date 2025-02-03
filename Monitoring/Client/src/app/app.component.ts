import {Component} from '@angular/core';
import {ServicesService} from './modules/admin/services/services.service';
import {TranslocoService} from '@ngneat/transloco';
import {AuthService} from './core/auth/auth.service';

// declare var APP_VERSION: string;

@Component({
    selector: 'app-root',
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.scss']
})
export class AppComponent {

    /**
     * Constructor
     */
    constructor(
        private _usersService: ServicesService,
        private _translocoService: TranslocoService,
        private _authService: AuthService
    ) {
        // this._translocoService.setActiveLang(this._authService.language);
    }

}
