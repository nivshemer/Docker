/* eslint-disable max-len */
/* eslint-disable @typescript-eslint/naming-convention */
/* eslint-disable arrow-body-style */
/* eslint-disable @typescript-eslint/member-ordering */

import {Component, ElementRef, Input, OnDestroy, OnInit, ViewChild} from '@angular/core';
import {Sort} from '@angular/material/sort';
import {MatTableDataSource} from '@angular/material/table';
import {Subject, takeUntil} from 'rxjs';
import {ServicesService} from '../services.service';
import {Service} from '../services.models';
import {fuseAnimations} from '@fuse/animations';
import {ToasterService} from '../../../../shared/services/toaster.service';
import {FunctionsService} from '../../../../shared/functions/functions.service';
import {translate} from '@ngneat/transloco';

const INTERVAL_TIME = 5 * 1000;

@Component({
    selector: 'app-services-table',
    templateUrl: './table.component.html',
    styleUrls: ['./table.component.scss'],
    animations: fuseAnimations
})
export class ServicesTableComponent implements OnInit, OnDestroy {
    @Input() set exportFormat(value: 'csv' | 'pdf') {
        if (value) {
            this._downloadFile(value);
        }
    }

    @ViewChild('pdfTable', {static: false}) pdfTable: ElementRef;

    _confirmUpdateData = true;
    _dataNotSorted: Service[];
    _isLoaded = false;
    _servicesDataSource: MatTableDataSource<Service> = new MatTableDataSource<Service>();
    _servicesTableColumns: string[] = ['Name', 'Version', 'Status'];
    _sort: Sort;

    _interval;

    private _unsubscribeAll: Subject<any> = new Subject<any>();

    constructor(
        private _servicesService: ServicesService,
        public _toasterService: ToasterService
    ) {
    }

    ngOnInit(): void {

        // Get the data
        this._servicesService.services$
            .pipe(takeUntil(this._unsubscribeAll))
            .subscribe((services) => {

                // Store the table data
                this._servicesDataSource.data = this._dataNotSorted = services;
                this._isLoaded = true;
            });
        this._interval = setInterval(() => {
            if (this._confirmUpdateData) {
                this._fetchData();
            }
        }, INTERVAL_TIME);
    }

    ngOnDestroy(): void {
        // Unsubscribe from all subscriptions
        this._unsubscribeAll.next(null);
        this._unsubscribeAll.complete();
        clearInterval(this._interval);
    }

    // -----------------------------------------------------------------------------------------------------
    // @ Public methods
    // -----------------------------------------------------------------------------------------------------

    sortData(sort: Sort): void {
        this._sort = sort;
        const dataNotSorted = this._dataNotSorted.slice();
        if (!sort.active || sort.direction === '') {
            this._servicesDataSource.data = dataNotSorted;
            return;
        }

        this._servicesDataSource.data = dataNotSorted.sort((a, b) => {
            const isAsc = sort.direction === 'asc';
            switch (sort.active) {
                case 'Name':
                    return this._compare(a.Name, b.Name, isAsc);
                case 'Version':
                    return this._compare(a.Version, b.Version, isAsc);
                case 'Status':
                    return this._compare(a.Status, b.Status, isAsc);
                default:
                    return 0;
            }
        });
    }

    trackByFn(index: number, user: Service): any {
        return user.Name || index;
    }

    // -----------------------------------------------------------------------------------------------------
    // @ Private methods
    // -----------------------------------------------------------------------------------------------------

    private _compare(a: number | string, b: number | string, isAsc: boolean): number {
        return (a < b ? -1 : 1) * (isAsc ? 1 : -1);
    }

    private _downloadFile(format: 'csv' | 'pdf'): void {
        const data = this._servicesDataSource.data;
        if (!data?.length) {
            this._toasterService.warning(translate('Toaster.NoDataForExport'));
            return;
        }
        if (format === 'pdf') {
            FunctionsService.downloadFilePDF(data, 'Services')
                .catch(() => {
                    this._toasterService.error(translate('Toaster.ExportError'));
                });
        }
        if (format === 'csv') {
            FunctionsService.downloadFileCSV(data, 'Services')
                .catch(() => {
                    this._toasterService.error(translate('Toaster.ExportError'));
                });
        }
    }

    private _fetchData(): void {
        this._confirmUpdateData = false;
        this._servicesService.getServices().pipe(takeUntil(this._unsubscribeAll)).subscribe(() => {
            this._confirmUpdateData = true;
            if (this._sort) {
                this.sortData(this._sort);
            }
        });
    }
}


