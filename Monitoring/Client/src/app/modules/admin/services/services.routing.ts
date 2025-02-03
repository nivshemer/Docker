import {Route} from '@angular/router';
import {ServicesComponent} from 'app/modules/admin/services/services.component';
import {ServicesResolver} from 'app/modules/admin/services/services.resolvers';
import {ServicesTableComponent} from './table/table.component';

export const servicesRoutes: Route[] = [
    {
        path: '',
        component: ServicesComponent,
        resolve: {
            data: ServicesResolver,
        },
        children: [
            {
                path: '',
                pathMatch: 'full',
                component: ServicesTableComponent
            }
        ]
    }
];
