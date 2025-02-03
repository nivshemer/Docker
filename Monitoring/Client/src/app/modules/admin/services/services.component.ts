/* eslint-disable @typescript-eslint/naming-convention */
import {Component, ElementRef, OnDestroy, ViewChild} from '@angular/core';
import {ServicesTableComponent} from './table/table.component';
import {Subject} from 'rxjs';
import {ServicesService} from './services.service';

@Component({
    selector: 'users',
    templateUrl: './services.component.html',
    // encapsulation: ViewEncapsulation.None,
    // changeDetection: ChangeDetectionStrategy.OnPush
})
export class ServicesComponent implements OnDestroy {
    @ViewChild('tableComponent') tableComponentRef: ElementRef<ServicesTableComponent>;

    exportFormat: 'csv' | 'pdf';
    private _unsubscribeAll: Subject<any> = new Subject<any>();

    constructor(private _usersService: ServicesService) {
    }

    ngOnDestroy(): void {
        // Unsubscribe from all subscriptions
        this._unsubscribeAll.next(null);
        this._unsubscribeAll.complete();
    }

    downloadFile(format: 'csv' | 'pdf'): void {
        this.exportFormat = format;
    }
}
