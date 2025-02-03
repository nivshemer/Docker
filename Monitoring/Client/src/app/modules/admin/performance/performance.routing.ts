import {Route} from '@angular/router';
import {ServicesResolver} from 'app/modules/admin/services/services.resolvers';
import {PerformanceComponent} from './performance.component';
import {PerformanceTableComponent} from './table/table.component';

export const performanceRoutes: Route[] = [
    {
        path: '',
        component: PerformanceComponent,
        resolve: {
            data: ServicesResolver,
        },
        children: [
            {
                path: '',
                pathMatch: 'full',
                component: PerformanceTableComponent
            }
        ]
    }
];
