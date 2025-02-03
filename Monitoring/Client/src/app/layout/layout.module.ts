import {NgModule} from '@angular/core';
import {LayoutComponent} from 'app/layout/layout.component';
import {EmptyLayoutModule} from 'app/layout/layouts/empty/empty.module';
import {CompactLayoutModule} from 'app/layout/layouts/vertical/compact/compact.module';
import {SettingsModule} from 'app/layout/common/settings/settings.module';
import {SharedModule} from 'app/shared/shared.module';

const layoutModules = [
    // Empty
    EmptyLayoutModule,

    CompactLayoutModule
];

@NgModule({
    declarations: [
        LayoutComponent
    ],
    imports: [
        SharedModule,
        SettingsModule,
        ...layoutModules
    ],
    exports: [
        LayoutComponent,
        ...layoutModules
    ]
})
export class LayoutModule {
}
