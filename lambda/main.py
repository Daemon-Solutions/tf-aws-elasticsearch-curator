#!/usr/bin/env python2

from __future__ import print_function

import curator
import copy
import json
import os
import re

from datetime import datetime
from elasticsearch import Elasticsearch


ES_HOST = os.environ['ES_HOST']
ES_PORT = int(os.environ['ES_PORT'])
SNAPSHOT_BUCKET = os.environ['SNAPSHOT_BUCKET']
SNAPSHOT_BUCKET_REGION = os.environ['SNAPSHOT_BUCKET_REGION']
SNAPSHOT_NAME = os.environ['SNAPSHOT_NAME']
TEST_MODE = os.environ['TEST_MODE'] == 'true'


def parse_index_filters(index_filters):
    result = []
    for index_filter in json.loads(index_filters):
        for key, value in index_filter.items():
            if isinstance(value, basestring):
                # Convert integer-strings to integers.
                if re.match(r'^-?\d+$', value):
                    index_filter[key] = int(value)
        result.append(index_filter)
    return result

DELETE_INDEX_FILTERS = parse_index_filters(os.environ['DELETE_INDEX_FILTERS'])
SNAPSHOT_INDEX_FILTERS = parse_index_filters(os.environ['SNAPSHOT_INDEX_FILTERS'])


def filter_indices(es, filters):
    # Fetch all the index names.
    print('Fetching all indices')
    indices = curator.IndexList(es)
    print('Found: {}'.format(indices.working_list()))

    # Filter them according to the provided filters.
    # Copy the filters because Curator mutates the objects.
    index_filters = copy.deepcopy(filters)
    print('Filtering indices with {}'.format(json.dumps(index_filters)))
    indices.iterate_filters({
        'filters': index_filters,
    })
    print('Matched: {}'.format(indices.working_list()))
    return indices


def lambda_handler(event, context):

    if not SNAPSHOT_INDEX_FILTERS and not DELETE_INDEX_FILTERS:
        raise ValueError('No value for delete_index_filters or snapshot_index_filters found - aborting')

    if SNAPSHOT_INDEX_FILTERS:
        if not SNAPSHOT_BUCKET or not SNAPSHOT_BUCKET_REGION or not SNAPSHOT_NAME:
            raise ValueError('Some required snapshot parameters have no values - aborting')

    # Create an Elasticsearch client.
    print('Connecting to Elasticsearch at {}:{}'.format(
         ES_HOST, ES_PORT,
    ))

    es = Elasticsearch(host=ES_HOST, port=ES_PORT)
    result = {}

    if SNAPSHOT_INDEX_FILTERS:
        snapshot_name = datetime.now().strftime(SNAPSHOT_NAME)
        indices = filter_indices(es, SNAPSHOT_INDEX_FILTERS)

        if TEST_MODE:
            result['snapshots'] = []
            result['test_mode'] = True

        else:
            if indices.working_list():
                if not curator.repository_exists(es, repository=SNAPSHOT_BUCKET):
                    print('Registering snapshot repository in s3://{}'.format(SNAPSHOT_BUCKET))
                    response = curator.create_repository(
                        client=es,
                        repo_type='s3',
                        bucket=SNAPSHOT_BUCKET,
                        region=SNAPSHOT_BUCKET_REGION
                    )
                    print('Response: ' + str(response))

                print('Creating a snapshot of indices')
                snapshot_indices = curator.Snapshot(
                    indices,
                    repository=SNAPSHOT_BUCKET,
                    snapshot=snapshot_name
                )
                snapshot_indices.do_action()
                result['snapshot'] = indices.working_list()

    if DELETE_INDEX_FILTERS:
        indices = filter_indices(es, DELETE_INDEX_FILTERS)

        if TEST_MODE:
            result['deleted'] = []
            result['test_mode'] = True
        else:
            if indices.working_list():
                print('Deleting indices')
                delete_indices = curator.DeleteIndices(indices)
                delete_indices.do_action()
                result['deleted'] = indices.working_list()

    return result
