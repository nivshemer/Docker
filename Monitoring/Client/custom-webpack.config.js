/* eslint-disable @typescript-eslint/naming-convention */
const webpack = require('webpack');

module.exports = {
    plugins: [
        new webpack.DefinePlugin({
            $ENV: {
                API_URL: JSON.stringify(process.env.API_URL || ''),
                BUILD_NUMBER: JSON.stringify(process.env.BUILD_NUMBER || 'no value'),
                MANAGEMENT_API_TAG: JSON.stringify(process.env.MANAGEMENT_API_TAG || 'no value'),
                MONITORING_URL_REQUEST: JSON.stringify(process.env.MONITORING_URL_REQUEST || ''),
            }
        })
    ]
};
