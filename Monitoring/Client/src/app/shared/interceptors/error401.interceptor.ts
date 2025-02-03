import {HttpErrorResponse, HttpEvent, HttpHandler, HttpInterceptor, HttpRequest} from '@angular/common/http';
import {catchError, Observable, of, take} from 'rxjs';
import {Injectable} from '@angular/core';
import {Router} from '@angular/router';
import {AuthService} from '../../core/auth/auth.service';
import {defaultRequestDescriptor} from '../constants';
import {MatDialog} from '@angular/material/dialog';

@Injectable()
export class Error401Interceptor implements HttpInterceptor {

    constructor(private router: Router, private _authService: AuthService,
                private _dialog: MatDialog) {
    }

    intercept(request: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
        return next.handle(request)
            .pipe(
                catchError((err, caught: Observable<HttpEvent<any>>) => {
                    console.log('error', err);
                    if (err instanceof HttpErrorResponse && err.status === 401) {
                        this._authService.signOut(this._authService.adminUser.Id).pipe(take(1)).subscribe(() => {
                            this.router.navigate(['/sign-in'], {queryParams: {accessDenied: 'Your token is expired'}})
                                .then(() => {
                                    this._dialog.closeAll();
                                    return of(err as any);
                                });
                        });
                    }
                    throw err;
                })
            );
    }
}
