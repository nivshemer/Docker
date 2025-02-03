import {Component, EventEmitter, Input, Output} from '@angular/core';

@Component({
    selector: 'app-export-button',
    templateUrl: './export-button.component.html',
    styleUrls: ['./export-button.component.scss']
})
export class ExportButtonComponent {
    @Input() formats: ('csv' | 'pdf')[] = ['csv', 'pdf'];
    @Output() export = new EventEmitter<void>();

}
