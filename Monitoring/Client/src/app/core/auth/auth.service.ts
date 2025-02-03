/* eslint-disable @typescript-eslint/naming-convention */
/* eslint-disable @typescript-eslint/member-ordering */

import {Injectable} from '@angular/core';
import {HttpClient} from '@angular/common/http';
import {Observable, of, switchMap, throwError} from 'rxjs';
import {UserService} from 'app/core/user/user.service';
import {BaseApi} from '../../shared/core/base-api';
import {Role, User} from '../../modules/admin/services/services.models';
import {CookieService} from 'ngx-cookie-service';
import {TranslocoService} from '@ngneat/transloco';

@Injectable()
export class AuthService extends BaseApi {
    private _authenticated: boolean = false;
    private _admin: User;
    private _language: string;

    /**
     * Constructor
     */
    constructor(
        private _httpClient: HttpClient,
        private _userService: UserService,
        private _cookiesService: CookieService,
        private _translocoService: TranslocoService
    ) {
        super(_httpClient);
    }

    // -----------------------------------------------------------------------------------------------------
    // @ Accessors
    // -----------------------------------------------------------------------------------------------------

    /**
     * Setter & getter for admin user
     */

    get adminUser(): User {
        return this._admin || (JSON.parse(localStorage.getItem('NivshemerUser')) ?? null);
    }

    set adminUser(user: User) {
        localStorage.setItem('NivshemerUser', JSON.stringify(user));
        this._admin = user;
    }

    /**
     * Setter & getter for language
     */

    get language(): string {
        return this._language || localStorage.getItem('NivshemerLanguage') || this._translocoService.getDefaultLang();
    }

    set language(language: string) {
        localStorage.setItem('NivshemerLanguage', language);
        this._language = language;
    }

    get adminRole(): Role {
        return (this.adminUser?.Role || '').toLowerCase() as Role;
    }

    // -----------------------------------------------------------------------------------------------------
    // @ Public methods
    // -----------------------------------------------------------------------------------------------------

    /**
     * Forgot password
     *
     * @param email
     */
    forgotPassword(email: string): Observable<any> {
        return this._httpClient.post('api/auth/forgot-password', email);
    }

    /**
     * Reset password
     *
     * @param password
     */
    resetPassword(password: string): Observable<any> {
        return this._httpClient.post('api/auth/reset-password', password);
    }

    /**
     * Sign in
     *
     * @param UserName
     * @param Password
     */
    signIn(UserName, Password): Observable<any> {
        // Throw error, if the user is already logged in
        if (this._authenticated) {
            return throwError({error: 'User is already logged in.'});
        }

        return this.post('Auth/AuthenticateUser', {UserName, Password}).pipe(
            switchMap((response: User) => {
                if (response.Role?.toLowerCase() === 'programmer') {
                    return throwError({error: 'Programmer can\'t enter to the system'});
                }

                // Store the access token in the local storage
                this.adminUser = response;

                // Set the authenticated flag to true
                this._authenticated = true;

                // Store the user on the user service
                this._admin = response;

                // Return a new observable with the response
                return of(response);
            })
        );
    }

    signInMock(UserName, Password): Observable<any> {
        // Throw error, if the user is already logged in
        if (this._authenticated) {
            return throwError({error: 'User is already logged in.'});
        }

        const obser = (UserName === 'mAdmin' && Password === 'mAdmin') ? of(true) : of(false);

        return obser.pipe(
            switchMap((isSucceded: boolean) => {
                // Store the access token in the local storage
                if (isSucceded) {
                    const user: User = {
                        Id: 'Id',
                        FirstName: 'Admin',
                        LastName: 'Admin',
                        Role: 'admin',
                        UserName: 'admin'
                    };
                    this.adminUser = user;

                    // Set the authenticated flag to true
                    this._authenticated = true;

                    // Store the user on the user service
                    this._admin = user;
                }

                // Return a new observable with the response
                return isSucceded ? of(true) : throwError({error: 'Credentials are not right'});
            })
        );
    }

    /**
     * Sign out
     */
    signOut(UserId: string = '', toLogOutKeycloak = false): Observable<any> {

        // console.log(this._cookiesService.check('X-Access-Token-Exp'));
        // console.log(this._cookiesService.check('X-Refresh-Token'));
        // console.log(this._cookiesService.check('X-Access-Token'));

        // Remove the admin user from the local storage
        localStorage.removeItem('NivshemerUser');
        this._cookiesService.deleteAll();
        this._cookiesService.delete('X-Access-Token-Exp');
        this._cookiesService.delete('X-Refresh-Token');
        this._cookiesService.delete('X-Access-Token');

        this._admin = null;

        // Set the authenticated flag to false
        this._authenticated = false;

        // Return the observable

        return toLogOutKeycloak ? this.post(`Auth/Logout/${UserId}`, {}) : of(true);

        // return of(true);
    }

    /**
     * Unlock session
     *
     * @param credentials
     */
    unlockSession(credentials: { email: string; password: string }): Observable<any> {
        return this._httpClient.post('api/auth/unlock-session', credentials);
    }

    /**
     * Check the authentication status
     */
    check(): Observable<boolean> {
        // // Check if the user is logged in
        // if (this._authenticated) {
        //     return of(true);
        // }

        // Check the access token availability
        if (!this.adminUser) {
            return of(false);
        }

        // If the access token exists and it didn't expire, sign in
        return of(true);
    }
}
