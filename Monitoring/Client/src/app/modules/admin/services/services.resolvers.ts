/* eslint-disable @typescript-eslint/naming-convention */

import {Injectable} from '@angular/core';
import {ActivatedRouteSnapshot, Resolve, RouterStateSnapshot} from '@angular/router';
import {Observable} from 'rxjs';
import {ServicesService} from 'app/modules/admin/services/services.service';
import {Service} from './services.models';

@Injectable({
    providedIn: 'root'
})
export class ServicesResolver implements Resolve<{ Services: Service[] }> {

    constructor(private _servicesService: ServicesService) {
    }

    resolve(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): Observable<{ Services: Service[] }> {
        return this._servicesService.getServices(true);
    }
}

