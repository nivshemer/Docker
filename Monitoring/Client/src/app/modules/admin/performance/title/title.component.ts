/* eslint-disable @typescript-eslint/naming-convention */
import {Component, EventEmitter, Output} from '@angular/core';
import {FormBuilder} from '@angular/forms';
import {ActivatedRoute} from '@angular/router';
import {fuseAnimations} from '../../../../../@fuse/animations';
import {MatDialog} from '@angular/material/dialog';
import {
    ExportFormatModalComponent
} from '../../../../shared/feature modules/entry/export-format-modal/export-format-modal.component';
import {take} from 'rxjs';
import {translate} from '@ngneat/transloco';
import {ServicesService} from '../../services/services.service';

@Component({
    selector: 'app-performance-title',
    styleUrls: ['./title.component.scss'],
    templateUrl: './title.component.html',
    animations: fuseAnimations
})
export class PerformanceTitleComponent {
    @Output() export = new EventEmitter<'csv' | 'pdf'>();

    constructor(
        private route: ActivatedRoute,
        private _formBuilder: FormBuilder,
        private _usersService: ServicesService,
        private _dialog: MatDialog
    ) {
    }

    openExportModal(): void {
        this._dialog.open(ExportFormatModalComponent, {
            data: {title: translate('Export.ExportPerformance')},
            panelClass: 'exportFormatModal'
        }).afterClosed().pipe(take(1))
            .subscribe((res) => {
                if (res) {
                    this.export.emit(res);
                }
            });
    }

}
