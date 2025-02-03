import {Component, OnInit, ViewChild, ViewEncapsulation} from '@angular/core';
import {FormBuilder, FormGroup, NgForm, Validators} from '@angular/forms';
import {ActivatedRoute, Router} from '@angular/router';
import {fuseAnimations} from '@fuse/animations';
import {FuseAlertType} from '@fuse/components/alert';
import {AuthService} from 'app/core/auth/auth.service';
import {TranslocoService} from '@ngneat/transloco';

@Component({
    selector: 'auth-sign-in',
    templateUrl: './sign-in.component.html',
    styleUrls: ['./sign-in.component.scss'],
    encapsulation: ViewEncapsulation.None,
    animations: fuseAnimations
})
export class AuthSignInComponent implements OnInit {
    @ViewChild('signInNgForm') signInNgForm: NgForm;

    alert: { type: FuseAlertType; message: string } = {
        type: 'success',
        message: ''
    };
    signInForm: FormGroup;
    showAlert: boolean = false;

    /**
     * Constructor
     */
    constructor(
        private _activatedRoute: ActivatedRoute,
        private _authService: AuthService,
        private _formBuilder: FormBuilder,
        private _router: Router,
        private _translocoService: TranslocoService
    ) {
    }

    // -----------------------------------------------------------------------------------------------------
    // @ Lifecycle hooks
    // -----------------------------------------------------------------------------------------------------

    /**
     * On init
     */
    ngOnInit(): void {
        this._showTokenExpiredMsg();

        // Create the form
        this.signInForm = this._formBuilder.group({
            // email: ['admin', [Validators.required]],
            // password: ['123Abc!', Validators.required],
            username: [localStorage.getItem('isDaniel') ? 'mAdmin' : '', [Validators.required, Validators.maxLength(20)]],
            password: [localStorage.getItem('isDaniel') ? 'mAdmin' : '', [Validators.required]],
            rememberMe: ['']
        });
    }

    // -----------------------------------------------------------------------------------------------------
    // @ Public methods
    // -----------------------------------------------------------------------------------------------------

    /**
     * Sign in
     */

    // Only AlphaNumeric
    keyPressAlphaNumeric(event): boolean {

        const inp = String.fromCharCode(event.keyCode);

        if (/[a-zA-Z0-9]/.test(inp)) {
            return true;
        } else {
            event.preventDefault();
            return false;
        }
    }

    setActiveLang(lang: 'en' | 'mx'): void {
        // Set the active lang
        this._authService.language = lang;
        this._translocoService.setActiveLang(lang);
    }

    signIn(): void {
        // this.keycloak.login();
        // this.keycloak.getKeycloakInstance().clientSecret = '123456';
        // this.keycloak.login();

        // this.oauthService.initCodeFlow();
        // this.oauthService.initLoginFlow();
        // this.oauthService.configure(authCodeFlowConfig);
        // this.oauthService.loadDiscoveryDocumentAndLogin();
        //
        // this.oauthService.loadUserProfile()
        //     .then(profile => {
        //         console.log('profile', profile);
        //     })

        // Return if the form is invalid
        if (this.signInForm.invalid) {
            return;
        }

        // Disable the form
        this.signInForm.disable();

        // Hide the alert
        this.showAlert = false;

        // Sign in
        const username = this.signInForm.get('username').value;
        this._authService.signInMock(username, this.signInForm.get('password').value)
            .subscribe(
                () => {
                    // Set the redirect url.
                    // The '/signed-in-redirect' is a dummy url to catch the request and redirect the user
                    // to the correct page after a successful sign in. This way, that url can be set via
                    // routing file and we don't have to touch here.
                    const redirectURL = this._activatedRoute.snapshot.queryParamMap.get('redirectURL') || '/signed-in-redirect';

                    // Navigate to the redirect url
                    // this._usersService.login('admin', '123Abc!').pipe(take(1)).subscribe(() => {
                    this._router.navigateByUrl(redirectURL);
                    // });

                },
                (error) => {
                    console.log('error', error);

                    // Re-enable the form
                    this.signInForm.enable();

                    // Reset the form
                    this.signInNgForm.resetForm();

                    // Set the alert
                    this.alert = {
                        type: 'error',
                        message: error.error
                    };

                    // Show the alert
                    this.showAlert = true;
                }
            );
    }

    // Private methods
    _showTokenExpiredMsg(): void {
        const tokenExpiredMsg = this._activatedRoute.snapshot.queryParams['accessDenied'];
        if (tokenExpiredMsg) {
            this.alert = {
                type: 'error',
                message: tokenExpiredMsg
            };
            this.showAlert = true;
            setTimeout(() => {
                this.showAlert = false;
            }, 6000);
        }
    }

}
