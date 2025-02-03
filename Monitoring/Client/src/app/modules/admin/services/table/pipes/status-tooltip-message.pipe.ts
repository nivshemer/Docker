import {Pipe, PipeTransform} from '@angular/core';
import {Status} from '../../services.models';
import {translate} from '@ngneat/transloco';

@Pipe({
    name: 'statusTooltipMessage'
})
export class StatusTooltipMessagePipe implements PipeTransform {

    transform(value: Status): string {
        const prefix = 'Services.StatusText.';
        switch (value) {
            case 'created':
                return translate(`${prefix}Created`);
            case 'exited':
                return translate(`${prefix}Exited`);
            default:
                return '';
        }
    }

}
