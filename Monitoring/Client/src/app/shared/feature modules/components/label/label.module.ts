import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { LabelComponent } from './label.component';
import {TranslocoCoreModule} from '../../../../core/transloco/transloco.module';



@NgModule({
    declarations: [
        LabelComponent
    ],
    exports: [
        LabelComponent
    ],
    imports: [
        CommonModule,
        TranslocoCoreModule
    ]
})
export class LabelModule { }
