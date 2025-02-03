from base64 import b64encode
from json import loads, dumps
from bases.FrameworkServices.SimpleService import SimpleService
import urllib3

ORDER = [
    'alerts'
]

CHARTS = {
    'alerts': {
        'options': [None, 'Alerts', 'alerts', 'overview', 'alerts.all', 'line'],
        'lines': [
            ['alerts.all', 'all', 'absolute']
        ]
    },
}


class Service(SimpleService):
    def __init__(self, configuration=None, name=None):
        SimpleService.__init__(self, configuration=configuration, name=name)
        self.order = ORDER
        self.definitions = CHARTS
        self.url = '{0}://{1}:{2}'.format(
            configuration.get('scheme', 'http'),
            configuration.get('host', '127.0.0.1'),
            configuration.get('port', 8070),
        )
        self.auth_url = '{0}://{1}:{2}'.format(
            configuration.get('scheme', 'http'),
            configuration.get('host', '127.0.0.1'),
            8078,
        )
        self.client_id = configuration['client_id']
        self.client_secret = configuration['client_secret']
        self.manager = urllib3.PoolManager()

    def _get_data(self):
        data = dict()

        access_token = self._get_access_token()
        headers = {'Authorization': "Bearer {0}".format(access_token), "Content-Type": 'application/json'}
        body = dumps({"status": 1, "descriptor": {"pageSize": 1}})
        self.debug("Headers: {0}".format(dumps(headers)))
        self.debug("Body: {0}".format(body))
        response = self.manager.request('POST', urljoin(self.url, '/api/Alerts/GetAlertsByStatus'), body=body,
                                        headers=headers)
        if response.status >= 300:
            raise RuntimeError("Failed to authenticate. Http status: {0}".format(response.status))
        self.info("Recieved alerts from server.")
        response = loads(response.data);

        data['alerts.all'] = response['totalResults']

        self.debug("Data: {0}".format(dumps(data)))

        return data

    def _get_access_token(self):
        response = self.manager.request('GET', urljoin(self.auth_url, '/.well-known/openid-configuration'))
        if response.status >= 300:
            raise RuntimeError(
                "Failed to get metadata from authentication service. Http status: {0}".format(response.status))
        metadata = loads(response.data)
        body = "grant_type=client_credentials&scope=generic"
        headers = "{0}:{1}".format(self.client_id, self.client_secret)
        headers = b64encode(headers.encode('utf-8')).decode()
        headers = "Basic {0}".format(headers)
        self.debug("Headers: {0}".format(dumps(headers)))
        self.debug("Body: {0}".format(dumps(body)))
        headers = {'Authorization': headers, "Content-Type": 'application/x-www-form-urlencoded'}
        response = self.manager.request('POST', metadata['token_endpoint'], body=body, headers=headers)
        if response.status >= 300:
            raise RuntimeError("Failed to authenticate. Http status: {0}".format(response.status))
        self.info("Authentication successful.")
        result = loads(response.data)
        self.debug("Access token parsed.")
        return result['access_token']


def urljoin(*segments):
    return '/'.join(s.strip('/') for s in segments)
