/* eslint-disable @typescript-eslint/naming-convention */
import {Injectable} from '@angular/core';
import {HttpClient} from '@angular/common/http';
import {BehaviorSubject, Observable, of, tap} from 'rxjs';
import {Service, Status} from './services.models';
import {Usage} from '../../../shared/models';
import {BaseApi} from '../../../shared/core/base-api';
import {AuthService} from '../../../core/auth/auth.service';
import {environment} from '../../../../environments/environment';
import {servicesAllowed} from '../../../shared/constants';

const mockServices = {
    'jovial_banach': {
        'status': 'running'
    },
    'hopeful_dewdney': {
        'status': 'exited'
    },
    'hardcore_ardinghelli': {
        'status': 'exited'
    },
    'nostalgic_mahavira': {
        'status': 'exited'
    },
    'bold_shannon': {
        'status': 'exited'
    },
    'gifted_archimedes': {
        'status': 'exited'
    },
    'wizardly_shtern': {
        'status': 'exited'
    },
    'vigilant_lederberg': {
        'status': 'exited'
    },
    'eager_agnesi': {
        'status': 'exited'
    },
    'elegant_lamarr': {
        'status': 'exited'
    },
    'nostalgic_roentgen': {
        'status': 'exited'
    },
    'zen_mclean': {
        'status': 'exited'
    },
    'serene_chaum': {
        'status': 'exited'
    },
    'distracted_hermann': {
        'status': 'exited'
    },
    'modest_wu': {
        'status': 'exited'
    },
    'flamboyant_williamson': {
        'status': 'exited'
    },
    'interesting_nobel': {
        'status': 'exited'
    },
    'strange_grothendieck': {
        'status': 'exited'
    },
    'pensive_black': {
        'status': 'exited'
    },
    'happy_shirley': {
        'status': 'exited'
    },
    'mngtclient': {
        'status': 'running'
    },
    'management-api': {
        'status': 'running',
        'version': '2.6.1',
        'usage': {
            'cpu': 0.2541147741147741,
            'memory': 127.3925899137152915
        }
    },
    'storage': {
        'status': 'running'
    },
    'keycloak': {
        'status': 'running'
    },
    'data-ready-processor': {
        'status': 'running'
    },
    'ota': {
        'status': 'running'
    },
    'device-key-store': {
        'status': 'running'
    },
    'assets': {
        'status': 'running'
    },
    'guid-generation': {
        'status': 'running'
    },
    'nginx': {
        'status': 'running'
    },
    'configuration': {
        'status': 'running'
    },
    'kibana': {
        'status': 'running'
    },
    'netdata': {
        'status': 'running'
    },
    'redis': {
        'status': 'running'
    },
    'rabbit-mq': {
        'status': 'running'
    },
    'postgres': {
        'status': 'running'
    },
    'redis-commander': {
        'status': 'running'
    },
    'filebeat': {
        'status': 'running'
    },
    'elasticsearch': {
        'status': 'running'
    }
};

@Injectable({
    providedIn: 'root'
})
export class ServicesService extends BaseApi {

    private _services: BehaviorSubject<Service[]> = new BehaviorSubject(null);

    constructor(
        private _httpClient: HttpClient,
        private _authService: AuthService,
    ) {
        super(_httpClient);
    }

    // -----------------------------------------------------------------------------------------------------
    // @ Accessors
    // -----------------------------------------------------------------------------------------------------

    /**
     * Getter for services
     */
    get services$(): Observable<Service[]> {
        return this._services.asObservable();
    }

    // -----------------------------------------------------------------------------------------------------
    // @ Public methods
    // -----------------------------------------------------------------------------------------------------

    getServices(forResolver = false): Observable<{ Services: Service[] }> {
        const currentServices = this._services.getValue();
        if (forResolver && currentServices) {
            this._services.next(currentServices);
            return;
        }
        const baseApiData = environment.baseApiData;

        return this._httpClient.get(baseApiData, {
            withCredentials: true
        }).pipe(
            tap((response: { Services: Service[] }) => {
                if (response) {
                    this._services.next(this._parseServices(response));
                    // this._services.next(this._parseServices(mockServices));
                }
            }),
        );
    }

    // private handleError(error: HttpErrorResponse): any {
    //     this._services.next(this._parseServices(mockServices));
    // }

    private _parseServices(services: any): Service[] {
        const res: Service[] = [];
        Object.entries(services).forEach((entry: [string, { status?: Status; version?: string; usage: Usage }]) => {
            const serviceName = entry[0];
            if (servicesAllowed.includes(serviceName)) {
                res.push({
                    Name: serviceName,
                    Status: entry[1].status,
                    Version: entry[1].version,
                    Usage: entry[1].usage
                });
            }
        });
        return res;
    }
}
