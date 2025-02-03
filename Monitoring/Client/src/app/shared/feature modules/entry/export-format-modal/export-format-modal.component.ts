import {Component, Inject, ViewEncapsulation} from '@angular/core';
import {MAT_DIALOG_DATA} from '@angular/material/dialog';

@Component({
    selector: 'app-export-format-modal',
    templateUrl: './export-format-modal.component.html',
    styles: [
        `
            .exportFormatModal {
                @screen md {
                    @apply w-128;
                }

                .mat-dialog-container {
                    padding: 0 !important;

                    h1 {
                        padding: 24px 0;
                    }
                }
            }
        `
    ],
    encapsulation: ViewEncapsulation.None
})
export class ExportFormatModalComponent {
    constructor(@Inject(MAT_DIALOG_DATA) public data: { title: string }) {
    }
}
