import {NgModule} from '@angular/core';
import {CommonModule} from '@angular/common';
import {ExportFormatModalComponent} from './export-format-modal.component';
import {MatDialogModule} from '@angular/material/dialog';
import {MatButtonModule} from '@angular/material/button';
import {SharedModule} from '../../../shared.module';
import {TranslocoCoreModule} from '../../../../core/transloco/transloco.module';


@NgModule({
    declarations: [
        ExportFormatModalComponent
    ],
    imports: [
        CommonModule,
        SharedModule,
        MatDialogModule,
        MatButtonModule,
        TranslocoCoreModule
    ],
    entryComponents: [ExportFormatModalComponent],
    exports: [
        ExportFormatModalComponent
    ]
})
export class ExportFormatModalModule {
}
