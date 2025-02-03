import {Injectable} from '@angular/core';
import {HttpClient, HttpErrorResponse, HttpParams} from '@angular/common/http';
import {Observable, throwError} from 'rxjs';
import {catchError} from 'rxjs/operators';
import {environment} from 'environments/environment';

@Injectable()
export class BaseApi {

    baseApi = environment.baseApi;

    constructor(public http: HttpClient) {
    }

    get(text: string, headers?: any, params?: HttpParams | {
        [param: string]: string | number | boolean | ReadonlyArray<string | number | boolean>;
    }): Observable<any> {
        const headersPlatform = {...headers, 'nl-platform': 'MOT'};
        return this.http.get(this.baseApi + text, {headers: headersPlatform, withCredentials: true, params})
            .pipe(
                catchError(this.handleError)
            );
    }

    post(text: string, obj: any, headers?: any): Observable<any> {
        const headersPlatform = {...headers, 'nl-platform': 'MOT'};
        return this.http.post(this.baseApi + text, obj, {headers: headersPlatform, withCredentials: true})
            .pipe(
                catchError(this.handleError)
            );
    }

    put(text: string, obj: any, headers?: any): Observable<any> {
        const headersPlatform = {...headers, 'nl-platform': 'MOT'};
        return this.http.put(this.baseApi + text, obj, {headers: headersPlatform, withCredentials: true})
            .pipe(
                catchError(this.handleError)
            );
    }

    delete(text: string, body?: any | null, headers?: any): Observable<any> {
        const headersPlatform = {...headers, 'nl-platform': 'MOT'};
        return this.http.delete(this.baseApi + text, {headers: headersPlatform, withCredentials: true, body})
            .pipe(
                catchError(this.handleError)
            );
    }

    private handleError(error: HttpErrorResponse): any {
        return throwError(error);
    }
}
