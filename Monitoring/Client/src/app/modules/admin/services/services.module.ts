import {NgModule} from '@angular/core';
import {RouterModule} from '@angular/router';
import {MatButtonModule} from '@angular/material/button';
import {MatDividerModule} from '@angular/material/divider';
import {MatIconModule} from '@angular/material/icon';
import {MatMenuModule} from '@angular/material/menu';
import {MatProgressBarModule} from '@angular/material/progress-bar';
import {MatSortModule} from '@angular/material/sort';
import {MatTableModule} from '@angular/material/table';
import {SharedModule} from 'app/shared/shared.module';
import {ServicesComponent} from 'app/modules/admin/services/services.component';
import {servicesRoutes} from 'app/modules/admin/services/services.routing';
import {MatFormFieldModule} from '@angular/material/form-field';
import {MatInputModule} from '@angular/material/input';
import {ServicesTableComponent} from './table/table.component';
import {MatSelectModule} from '@angular/material/select';
import {MatTooltipModule} from '@angular/material/tooltip';
import {MatDialogModule} from '@angular/material/dialog';
import {MatChipsModule} from '@angular/material/chips';
import {MatPaginatorModule} from '@angular/material/paginator';
import {MatProgressSpinnerModule} from '@angular/material/progress-spinner';
import {ServicesTitleComponent} from './title/title.component';
import {ExportButtonModule} from '../../../shared/feature modules/components/export-button/export-button.module';
import {TranslocoCoreModule} from '../../../core/transloco/transloco.module';
import {StatusTooltipMessagePipe} from './table/pipes/status-tooltip-message.pipe';
import {
    ExportFormatModalModule
} from '../../../shared/feature modules/entry/export-format-modal/export-format-modal.module';

@NgModule({
    declarations: [
        ServicesComponent,
        ServicesTableComponent,
        ServicesTitleComponent,
        StatusTooltipMessagePipe,
    ],
    imports: [
        RouterModule.forChild(servicesRoutes),
        MatButtonModule,
        MatDividerModule,
        MatIconModule,
        MatMenuModule,
        MatProgressBarModule,
        MatSortModule,
        MatTableModule,
        SharedModule,
        MatFormFieldModule,
        MatInputModule,
        MatSelectModule,
        MatTooltipModule,
        MatDialogModule,
        MatChipsModule,
        MatPaginatorModule,
        MatProgressSpinnerModule,
        ExportButtonModule,
        TranslocoCoreModule,
        ExportFormatModalModule
    ]
})
export class ServicesModule {
}
