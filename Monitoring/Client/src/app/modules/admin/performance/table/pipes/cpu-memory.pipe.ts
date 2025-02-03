import {Pipe, PipeTransform} from '@angular/core';
import {FunctionsService} from '../../../../../shared/functions/functions.service';

@Pipe({
    name: 'cpuMemory'
})
export class CpuMemoryPipe implements PipeTransform {

    transform(obj: any, field: 'cpu' | 'memory'): string {
        return FunctionsService.usagePropValue(obj, field);
    }

}
