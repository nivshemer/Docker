import {Injectable} from '@angular/core';
import {ToastrService} from 'ngx-toastr';
import {translate} from '@ngneat/transloco';

@Injectable({
    providedIn: 'root'
})
export class ToasterService {

    constructor(public toasterService: ToastrService) {
    }

    error(message: string): void {
        this.toasterService.error(message, translate('Common.Error'), {positionClass: 'toast-bottom-center'});
    }

    success(message: string): void {
        this.toasterService.success(message, translate('Common.Success'), {positionClass: 'toast-bottom-center'});
    }

    warning(message): void {
        this.toasterService.warning(message, '', {positionClass: 'toast-bottom-center'});
    }


}
