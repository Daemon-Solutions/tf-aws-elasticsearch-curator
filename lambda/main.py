#!/usr/bin/env python2

from __future__ import print_function

import curator
import copy
import json
import os
import re

from elasticsearch import Elasticsearch


def get_index_filters():
    index_filters = []
    for index_filter in json.loads(os.environ['INDEX_FILTERS']):
        for key, value in index_filter.items():
            if isinstance(value, basestring):
                # Convert integer-strings to integers.
                if re.match(r'^-?\d+$', value):
                    index_filter[key] = int(value)
        index_filters.append(index_filter)
    return index_filters


ES_HOST = os.environ['ES_HOST']
ES_PORT = int(os.environ['ES_PORT'])
INDEX_FILTERS = get_index_filters()
TEST_MODE = os.environ['TEST_MODE'] == 'true'


def lambda_handler(event, context):

    if not INDEX_FILTERS:
        raise ValueError('No value for index_filters - aborting')

    # Create an Elasticsearch client.
    print('Connecting to Elasticsearch at {}:{}'.format(
        ES_HOST, ES_PORT,
    ))
    es = Elasticsearch(host=ES_HOST, port=ES_PORT)

    # Fetch all the index names.
    print('Fetching all indices')
    indices = curator.IndexList(es)
    print('Found: {}'.format(indices.working_list()))

    # Filter them according to the provided filters.
    # Copy the filters because Curator mutates the objects.
    index_filters = copy.deepcopy(INDEX_FILTERS)
    print('Filtering indices with {}'.format(json.dumps(index_filters)))
    indices.iterate_filters({
        'filters': index_filters,
    })
    print('Matched: {}'.format(indices.working_list()))

    if TEST_MODE:
        return {'deleted': [], 'test_mode': True}
    else:
        if indices.working_list():
            print('Deleting indices')
            delete_indices = curator.DeleteIndices(indices)
            delete_indices.do_action()
        return {'deleted': indices.working_list()}
