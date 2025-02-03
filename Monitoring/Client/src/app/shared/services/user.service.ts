/* eslint-disable @typescript-eslint/naming-convention */

import {Injectable} from '@angular/core';
import {BaseApi} from '../core/base-api';
import {HttpClient} from '@angular/common/http';
import {Observable} from 'rxjs';
import {User} from '../../modules/admin/services/services.models';

@Injectable({
    providedIn: 'root'
})
export class UserService extends BaseApi {

    constructor(public http: HttpClient) {
        super(http);
    }

    // Requests

    login(UserName, Password): Observable<any> {
        return this.post('Auth/AuthenticateUser', {UserName, Password});
    }
}
