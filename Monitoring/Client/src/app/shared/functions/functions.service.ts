/* eslint-disable @typescript-eslint/naming-convention */
import {saveAs} from 'file-saver';
import {jsPDF} from 'jspdf';
import autoTable, {RowInput} from 'jspdf-autotable';
import * as moment from 'moment';
import {Injectable} from '@angular/core';
import {translate} from '@ngneat/transloco';
import {Usage} from '../models';

interface Header {
    name?: string;
    property?: string;
}

const columnsForExport: { Services: Header[]; Performance: Header[] } =
    {
        Services: [{name: 'Name', property: 'Name'}, {name: 'Version', property: 'Version'}, {
            name: 'Status',
            property: 'Status'
        }],
        Performance: [{name: 'ProcessName', property: 'Name'}, {name: 'Cpu', property: 'cpu'}, {
            name: 'Memory',
            property: 'memory'
        }]
    };

@Injectable({
    providedIn: 'root'
})
export class FunctionsService {

    static downloadFileCSV(data: any[], name: 'Performance' | 'Services'): Promise<string> {
        const date = new Date().toLocaleDateString() + ' ' + new Date().toLocaleTimeString();
        const nameTranslated = translate(`${name}.Title`);
        const fileName = `${nameTranslated}_${date}.csv`;

        try {
            // const headers = Object.keys(data[0])?.filter(key => !propertiesNotForExport.includes(key));
            const headers = columnsForExport[name].map(o => o.name);
            const properties = columnsForExport[name].map(o => o.property);
            const csv = this.bodyBuildingCsv(data, properties);
            csv.unshift(headers.map(header => translate(name + '.' + (columnsForExport[name].find(h => h.property === header)?.property || header))).join(','));
            const csvArray = csv.join('\r\n');
            const blob = new Blob([csvArray], {type: 'text/csv'});
            saveAs(blob, fileName);
        } catch (e) {
            return Promise.reject();
        }
        return Promise.resolve(fileName);
    }

    static downloadFilePDF(data: any[], name: 'Performance' | 'Services'): Promise<string> {
        // https://github.com/simonbengtsson/jsPDF-AutoTable

        const date = new Date().toLocaleDateString() + ' ' + new Date().toLocaleTimeString();
        const nameTranslated = translate(`${name}.Title`);
        const titleTranslated = translate(`${name}.Export.Title`, {date});
        const fileName = `${nameTranslated}_${date}.pdf`;

        try {
            const doc = new jsPDF('landscape');
            // const headers = Object.keys(data[0])?.filter(key => !propertiesNotForExport.includes(key));
            const headers = columnsForExport[name].map(o => o.name);
            const properties = columnsForExport[name].map(o => o.property);

            const body = this.bodyBuildingPdf(data, properties);

            doc.text(titleTranslated, 100, 7, {align: 'justify'});
            autoTable(doc, {
                head: [headers.map(header => translate(name + '.' +
                    (columnsForExport[name].find(h => h.property === header)?.property || header)))],
                body,
                headStyles: {
                    minCellWidth: 270 / headers.length,
                    fillColor: [254, 169, 49]
                },
                theme: 'grid'
            });
            doc.save(fileName);
        } catch (e) {
            return Promise.reject(e);
        }
        return Promise.resolve(fileName);
    }

    static timeLocal(timeString: string): string {
        // const milliSeconds = new Date(timeString).valueOf() - new Date().getTimezoneOffset() * 1000 * 60;
        const milliSeconds = new Date(timeString).valueOf();
        const timeFormat = false ? 'hh:mm:ss A' : 'HH:mm:ss';
        const local = Intl.DateTimeFormat().resolvedOptions().locale;
        return moment(milliSeconds).locale(local).format(timeFormat);
    }

    static toTitleCase(str: string): string {
        return str ? str[0].toUpperCase() + str.slice(1).toLowerCase() : '';
    }

    static usagePropValue(obj: any, field: 'cpu' | 'memory'): string {
        const usage: Usage = obj['Usage'];
        return (usage?.cpu || usage?.memory) ? obj['Usage'][field].toFixed(2) + '%' : '';
    }

    /**
     * Private methods
     */

    private static bodyBuildingCsv(data: any[], properties: string[]): string[] {
        return data.map(row => this.valueFieldTransform(properties, row).join(','));
    }

    private static bodyBuildingPdf(data: any[], properties: string[]): RowInput[] {
        return data.map(row => this.valueFieldTransform(properties, row));
    }

    private static valueFieldTransform(properties: string[], row: any): string[] {
        return properties.map((fieldProperty) => {
            const getUsageProp = row['Usage'] && (fieldProperty === 'cpu' || fieldProperty === 'memory');
            if (getUsageProp) {
                return FunctionsService.usagePropValue(row, fieldProperty);
            }
            return row[fieldProperty] || '';
        });
    }
}


