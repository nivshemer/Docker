import {NgModule} from '@angular/core';
import {PerformanceComponent} from './performance.component';
import {PerformanceTableComponent} from './table/table.component';
import {PerformanceTitleComponent} from './title/title.component';
import {
    ExportFormatModalModule
} from '../../../shared/feature modules/entry/export-format-modal/export-format-modal.module';
import {TranslocoCoreModule} from '../../../core/transloco/transloco.module';
import {ExportButtonModule} from '../../../shared/feature modules/components/export-button/export-button.module';
import {MatProgressSpinnerModule} from '@angular/material/progress-spinner';
import {MatPaginatorModule} from '@angular/material/paginator';
import {MatChipsModule} from '@angular/material/chips';
import {MatDialogModule} from '@angular/material/dialog';
import {MatTooltipModule} from '@angular/material/tooltip';
import {MatInputModule} from '@angular/material/input';
import {MatFormFieldModule} from '@angular/material/form-field';
import {SharedModule} from '../../../shared/shared.module';
import {MatTableModule} from '@angular/material/table';
import {MatSortModule} from '@angular/material/sort';
import {MatProgressBarModule} from '@angular/material/progress-bar';
import {MatMenuModule} from '@angular/material/menu';
import {MatIconModule} from '@angular/material/icon';
import {MatDividerModule} from '@angular/material/divider';
import {MatButtonModule} from '@angular/material/button';
import {RouterModule} from '@angular/router';
import {performanceRoutes} from './performance.routing';
import { CpuMemoryPipe } from './table/pipes/cpu-memory.pipe';


@NgModule({
    declarations: [
        PerformanceComponent,
        PerformanceTableComponent,
        PerformanceTitleComponent,
        CpuMemoryPipe
    ],
    imports: [
        RouterModule.forChild(performanceRoutes),
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
export class PerformanceModule {
}
