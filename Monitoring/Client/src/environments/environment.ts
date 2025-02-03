// This file can be replaced during build by using the `fileReplacements` array.
// `ng build --prod` replaces `environment.ts` with `environment.prod.ts`.
// The list of file replacements can be found in `angular.json`.

export const environment = {
    production: false,
    // baseApi: 'https://nl-api.nanolocksecurity.nl/api/'
    // baseApi: 'https://staging-api.nanolocksecurity.nl/api/'
    // baseApi: 'https://dev01-api.nanolocksecurity.nl/api/'
    baseApi: 'http://localhost:8070/api/',
    baseApiData: 'http://dev01.nanolocksecurity.nl:8082/continuersStatus'
};

/*
 * For easier debugging in development mode, you can import the following file
 * to ignore zone related error stack frames such as `zone.run`, `zoneDelegate.invokeTask`.
 *
 * This import should be commented out in production mode because it will have a negative impact
 * on performance if an error is thrown.
 */
// import 'zone.js/plugins/zone-error';  // Included with Angular CLI.
