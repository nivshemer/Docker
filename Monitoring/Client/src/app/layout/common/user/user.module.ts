import {NgModule} from '@angular/core';
import {MatButtonModule} from '@angular/material/button';
import {MatDividerModule} from '@angular/material/divider';
import {MatIconModule} from '@angular/material/icon';
import {MatMenuModule} from '@angular/material/menu';
import {UserComponent} from 'app/layout/common/user/user.component';
import {SharedModule} from 'app/shared/shared.module';
import {RouterModule} from '@angular/router';
import {MatDialogModule} from '@angular/material/dialog';
import {MatSelectModule} from '@angular/material/select';
import {TranslocoCoreModule} from '../../../core/transloco/transloco.module';

@NgModule({
    declarations: [
        UserComponent
    ],
    imports: [
        MatButtonModule,
        MatDividerModule,
        MatIconModule,
        MatMenuModule,
        SharedModule,
        RouterModule,
        MatDialogModule,
        MatSelectModule,
        TranslocoCoreModule
    ],
    exports: [
        UserComponent
    ]
})
export class UserModule {
}
