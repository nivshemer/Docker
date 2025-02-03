import {Pipe, PipeTransform} from '@angular/core';
import {translate} from '@ngneat/transloco';

@Pipe({
    name: 'exportButtonTooltip'
})
export class TooltipPipe implements PipeTransform {
    transform(value: ('csv' | 'pdf')[]): string {
        if (value.length === 1) {
            return translate('Actions.ExportAs', {format: value[0].toUpperCase()});
        }
        return translate('Actions.ExportAsCSVorPDF');
    }

}
