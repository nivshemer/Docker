# -*- coding: utf-8 -*-
# Description: rabbitmq netdata python.d module

from json import loads
from bases.FrameworkServices.UrlService import UrlService

API_NODE = 'api/nodes'
API_OVERVIEW = 'api/overview'

NODE_STATS = [
    'fd_used',
    'mem_used',
    'sockets_used',
    'proc_used',
    'disk_free',
    'run_queue'
]

OVERVIEW_STATS = [
    'object_totals.channels',
    'object_totals.consumers',
    'object_totals.connections',
    'object_totals.queues',
    'object_totals.exchanges',
    'queue_totals.messages_ready',
    'queue_totals.messages_unacknowledged',
    'message_stats.ack',
    'message_stats.redeliver',
    'message_stats.deliver',
    'message_stats.publish'
]

ORDER = [
    'queued_messages',
    'message_rates',
    'global_counts',
    'file_descriptors',
    'socket_descriptors',
    'erlang_processes',
    'erlang_run_queue',
    'memory',
    'disk_space'
]

CHARTS = {
    'file_descriptors': {
        'options': [None, 'File Descriptors', 'descriptors', 'overview', 'rabbitmq.file_descriptors', 'line'],
        'lines': [
            ['fd_used', 'used', 'absolute']
        ]
    },
    'memory': {
        'options': [None, 'Memory', 'MiB', 'overview', 'rabbitmq.memory', 'area'],
        'lines': [
            ['mem_used', 'used', 'absolute', 1, 1 << 20]
        ]
    },
    'disk_space': {
        'options': [None, 'Disk Space', 'GiB', 'overview', 'rabbitmq.disk_space', 'area'],
        'lines': [
            ['disk_free', 'free', 'absolute', 1, 1 << 30]
        ]
    },
    'socket_descriptors': {
        'options': [None, 'Socket Descriptors', 'descriptors', 'overview', 'rabbitmq.sockets', 'line'],
        'lines': [
            ['sockets_used', 'used', 'absolute']
        ]
    },
    'erlang_processes': {
        'options': [None, 'Erlang Processes', 'processes', 'overview', 'rabbitmq.processes', 'line'],
        'lines': [
            ['proc_used', 'used', 'absolute']
        ]
    },
    'erlang_run_queue': {
        'options': [None, 'Erlang Run Queue', 'processes', 'overview', 'rabbitmq.erlang_run_queue', 'line'],
        'lines': [
            ['run_queue', 'length', 'absolute']
        ]
    },
    'global_counts': {
        'options': [None, 'Global Counts', 'counts', 'overview', 'rabbitmq.global_counts', 'line'],
        'lines': [
            ['object_totals_channels', 'channels', 'absolute'],
            ['object_totals_consumers', 'consumers', 'absolute'],
            ['object_totals_connections', 'connections', 'absolute'],
            ['object_totals_queues', 'queues', 'absolute'],
            ['object_totals_exchanges', 'exchanges', 'absolute']
        ]
    },
    'queued_messages': {
        'options': [None, 'Queued Messages', 'messages', 'overview', 'rabbitmq.queued_messages', 'stacked'],
        'lines': [
            ['queue_totals_messages_ready', 'ready', 'absolute'],
            ['queue_totals_messages_unacknowledged', 'unacknowledged', 'absolute']
        ]
    },
    'message_rates': {
        'options': [None, 'Message Rates', 'messages/s', 'overview', 'rabbitmq.message_rates', 'line'],
        'lines': [
            ['message_stats_ack', 'ack', 'incremental'],
            ['message_stats_redeliver', 'redeliver', 'incremental'],
            ['message_stats_deliver', 'deliver', 'incremental'],
            ['message_stats_publish', 'publish', 'incremental']
        ]
    }
}


class Service(UrlService):
    def __init__(self, configuration=None, name=None):
        UrlService.__init__(self, configuration=configuration, name=name)
        self.order = ORDER
        self.definitions = CHARTS
        self.url = '{0}://{1}:{2}'.format(
            configuration.get('scheme', 'http'),
            configuration.get('host', '127.0.0.1'),
            configuration.get('port', 15672),
        )
        self.node_name = str()

    def check(self):
        """
        Parse configuration, check if redis is available, and dynamically create chart lines data
        :return: boolean
        """
        if not UrlService.check(self):
            return False
        data = self._get_queues()

        if not data:
            return False

        for queue in data:
            self._update_queue_chart(queue)

        return True

    def _get_queues(self):
        try:
            url = '{0}/{1}'.format(self.url, "api/queues")
            raw = self._get_raw_data(url)
            if not raw:
                return None
            data = loads(raw)
            return data
        except Exception as error:
            self.error("_get_queues() => Error getting queues: {error})".format(error=error))
        return None

    def _update_queue_chart(self, queue):
        queue_name = queue['name']
        definition = "queue_{0}".format(queue_name.lower().replace(' ', '').replace('|', '.'))
        if definition in self.order:
            return
        queue_options = {
            "options": [None, queue_name, 'messages/s', 'queues',
                        'rabbitmq.{0}.message_rates'.format(queue_name.lower().replace(' ', '').replace('|', '.')),
                        'line'],
            "lines": [
                ['{0}_messages_stats_total'.format(definition), 'total', 'absolute'],
                ['{0}_messages_stats_ready'.format(definition), 'ready', 'absolute'],
                ['{0}_messages_stats_unacked'.format(definition), 'unacked', 'incremental'],
                ['{0}_messages_stats_delivered'.format(definition), 'delivered', 'incremental'],
                ['{0}_messages_stats_redelivered'.format(definition), 'redelivered', 'incremental'],
                ['{0}_messages_stats_acked'.format(definition), 'acked', 'incremental']
            ]
        }
        self.order.append(definition)
        self.definitions[definition] = queue_options

    def _get_queues_data(self):
        data = self._get_queues()
        if not data:
            return None

        stats = {}

        for queue in data:
            definition = "queue_{0}".format(queue['name'].lower())
            stats['{0}_messages_stats_acked'.format(definition)] = Service.get_value_by_path(queue,
                                                                                             'message_stats', 'ack',
                                                                                             default=0)
            stats['{0}_messages_stats_unacked'.format(definition)] = Service.get_value_by_path(queue, 'message_stats',
                                                                                               'get_no_ack', default=0)
            stats['{0}_messages_stats_delivered'.format(definition)] = Service.get_value_by_path(queue, 'message_stats',
                                                                                                 'deliver_get',
                                                                                                 default=0)
            stats['{0}_messages_stats_redelivered'.format(definition)] = Service.get_value_by_path(queue,
                                                                                                   'message_stats',
                                                                                                   'redeliver',
                                                                                                   default=0)
            stats['{0}_messages_stats_total'.format(definition)] = Service.get_value_by_path(queue, 'messages',
                                                                                             default=0)
            stats['{0}_messages_stats_ready'.format(definition)] = Service.get_value_by_path(queue, 'messages_ready',
                                                                                             default=0)

        return stats

    def _get_data(self):
        data = dict()

        stats = self.get_overview_stats()

        if not stats:
            return None

        data.update(stats)

        stats = self.get_nodes_stats()

        if not stats:
            return None

        data.update(stats)

        stats = self._get_queues_data()

        if stats:
            data.update(stats)

        return data or None

    def get_overview_stats(self):
        url = '{0}/{1}'.format(self.url, API_OVERVIEW)

        raw = self._get_raw_data(url)

        if not raw:
            return None

        data = loads(raw)

        self.node_name = data['node']

        return fetch_data(raw_data=data, metrics=OVERVIEW_STATS)

    def get_nodes_stats(self):
        url = '{0}/{1}/{2}'.format(self.url, API_NODE, self.node_name)

        raw = self._get_raw_data(url)

        if not raw:
            return None

        data = loads(raw)

        return fetch_data(raw_data=data, metrics=NODE_STATS)

    @classmethod
    def get_value_by_path(cls, data, *path, **kargs):
        for segment in path:
            if data is None:
                return kargs.get('default')
            data = data.get(segment)
        return data


def fetch_data(raw_data, metrics):
    data = dict()

    for metric in metrics:
        value = raw_data
        metrics_list = metric.split('.')
        try:
            for m in metrics_list:
                value = value[m]
        except KeyError:
            continue
        data['_'.join(metrics_list)] = value

    return data
