from json import loads, dumps
from bases.FrameworkServices.UrlService import UrlService
import sys

API_HEALTH = 'health'

ORDER = [

]

CHARTS = {
    'counters': {
        'options': [None, 'Counters', 'actions', 'overview', 'service.counters', 'line'],
        'lines': [
            ['fd_used', 'used', 'absolute']
        ]
    },
    'memory': {
        'options': [None, 'Memory', 'MiB', 'overview', 'rabbitmq.memory', 'area'],
        'lines': [
            ['mem_used', 'used', 'absolute', 1, 1 << 20]
        ]
    }
}


class Service(UrlService):
    def __init__(self, configuration=None, name=None):
        UrlService.__init__(self, configuration=configuration, name=name)
        self.order = []
        self.definitions = {}
        self.url = '{0}://{1}:{2}'.format(
            configuration.get('scheme', 'http'),
            configuration.get('host', '127.0.0.1'),
            configuration.get('port', 15672),
        )
        self.groups = configuration.get('groups') or []

    def check(self):
        """
        Parse configuration, check if redis is available, and dynamically create chart lines data
        :return: boolean
        """
        if not UrlService.check(self):
            return False
        data = self._get_counters()

        if not data:
            return False

        self._update_counter_chart(data)

        return True

    def _get_data(self):
        data = dict()

        stats = self._get_counter_data()

        if not stats:
            return None

        data.update(stats)

        return data or None

    def _get_counters(self):
        try:
            url = '{0}/{1}'.format(self.url, API_HEALTH)
            raw = self._get_raw_data(url)
            if not raw:
                return None
            data = loads(raw)
            return data.get('counters')
        except Exception as error:
            self.error("_get_counters() => Error getting counters: {error})".format(error=error))
        return None

    def _update_counter_chart(self, counters):
        definition = "service.counter"
        if definition in self.order:
            return

        if sys.version_info[0] > 2:
            counters_list = counters.items()
        else:
            counters_list = list(counters.iteritems())

        counters_options = {
            'options': [None, 'Counters', 'actions', 'overview', 'service.counters', 'line'],
            "lines": [[Service._counter_key(key), key.lower(), 'incremental'] for key, value in counters_list]
        }

        self.order.append(definition)
        self.definitions[definition] = counters_options

        self.debug('_update_counter_chart() => {0}'.format(dumps(counters)))
        self.debug('_update_counter_chart() => Number of counters: {0}'.format(len(counters_list)))
        for key, value in counters_list:
            self.debug('_update_counter_chart() => Key: {0}, Value: {1}'.format(key, value))
            groups = [x for x in self.groups if key.startswith(x)]
            for group in groups:
                group_key = Service._counter_key(group)
                group = self.definitions.get(group_key)
                if group is None:
                    self.definitions[group_key] = group = {
                        'options': [None, group, 'actions', 'groups', group_key, 'line'],
                        "lines": []
                    }
                    self.order.append(group_key)

                group['lines'].append([Service._counter_key(key), key[len(group)-2:].lower(), 'incremental'])
                self.debug('_update_counter_chart() => Added group: {0}'.format(group_key))

    def _get_counter_data(self):
        data = self._get_counters()
        if not data:
            return None

        if sys.version_info[0] > 2:
            counters_list = data.items()
        else:
            counters_list = data.iteritems()

        stats = {Service._counter_key(key): value for key, value in counters_list}

        return stats

    @classmethod
    def _counter_key(cls, counter_name):
        return 'service.counter.{0}'.format(counter_name)
