import {Component, Input, OnInit} from '@angular/core';

@Component({
    selector: 'app-label',
    templateUrl: './label.component.html',
    styleUrls: ['./label.component.scss']
})
export class LabelComponent implements OnInit {
    @Input() class: string = 'left-0 right-0';

    constructor() {
    }

    ngOnInit(): void {
    }

}
