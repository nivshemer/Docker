import {
    Translation,
    TRANSLOCO_CONFIG,
    TRANSLOCO_LOADER,
    translocoConfig,
    TranslocoModule,
    TranslocoService
} from '@ngneat/transloco';
import {APP_INITIALIZER, NgModule} from '@angular/core';
import {environment} from 'environments/environment';
import {TranslocoHttpLoader} from 'app/core/transloco/transloco.http-loader';
import {AuthService} from '../auth/auth.service';

@NgModule({
    exports: [
        TranslocoModule
    ],
    providers: [
        {
            // Provide the default Transloco configuration
            provide: TRANSLOCO_CONFIG,
            useValue: translocoConfig({
                availableLangs: [
                    {
                        id: 'en',
                        label: 'English'
                    },
                    {
                        id: 'mx',
                        label: 'Spanish'
                    }
                ],
                defaultLang: 'en',
                fallbackLang: 'en',
                reRenderOnLangChange: true,
                prodMode: environment.production,
                missingHandler: {
                    useFallbackTranslation: true
                }
            })
        },
        {
            // Provide the default Transloco loader
            provide: TRANSLOCO_LOADER,
            useClass: TranslocoHttpLoader
        },
        {
            // Preload the default language before the app starts to prevent empty/jumping content
            provide: APP_INITIALIZER,
            deps: [TranslocoService],
            useFactory: (translocoService: TranslocoService): any => (): Promise<Translation> => {
                const defaultLang = translocoService.getDefaultLang();
                translocoService.setActiveLang(localStorage.getItem('NivshemerLanguage') || defaultLang);
                return translocoService.load(defaultLang).toPromise();
            },
            multi: true
        }
    ]
})
export class TranslocoCoreModule {
    constructor(private _authService: AuthService) {
    }
}
