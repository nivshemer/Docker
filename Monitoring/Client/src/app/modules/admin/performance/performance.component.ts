import {Component} from '@angular/core';

@Component({
    selector: 'app-performance',
    templateUrl: './performance.component.html'
})
export class PerformanceComponent {
    exportFormat: 'csv' | 'pdf';

    downloadFile(format: 'csv' | 'pdf'): void {
        this.exportFormat = format;
    }

}
