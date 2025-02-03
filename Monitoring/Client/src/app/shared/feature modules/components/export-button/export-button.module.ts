import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ExportButtonComponent } from './export-button.component';
import {MatTooltipModule} from '@angular/material/tooltip';
import {MatIconModule} from '@angular/material/icon';
import {MatButtonModule} from '@angular/material/button';
import { TooltipPipe } from './tooltip.pipe';
import {TranslocoCoreModule} from '../../../../core/transloco/transloco.module';



@NgModule({
    declarations: [
        ExportButtonComponent,
        TooltipPipe
    ],
    exports: [
        ExportButtonComponent
    ],
    imports: [
        CommonModule,
        MatTooltipModule,
        MatIconModule,
        MatButtonModule,
        TranslocoCoreModule
    ]
})
export class ExportButtonModule { }
