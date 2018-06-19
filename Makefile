# http://clarkgrubb.com/makefile-style-guide

MAKEFLAGS += --warn-undefined-variables --no-print-directory
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := test
.DELETE_ON_ERROR:
.SUFFIXES:


ifndef AWS_DEFAULT_REGION
$(error AWS_DEFAULT_REGION is not set)
endif


# Find and use the first Amazon Elasticsearch cluster in the account. 
es_domain = $(shell aws es list-domain-names --region $(AWS_DEFAULT_REGION) --query DomainNames[0].DomainName --output text)
es_endpoint = $(shell aws es describe-elasticsearch-domain --region $(AWS_DEFAULT_REGION) --domain-name $(es_domain) --query DomainStatus.Endpoints --output text)


# Export environment variables for the Lambda function to run.
export ES_HOST=$(es_endpoint)
export ES_PORT=443
export ES_REGION=$(AWS_DEFAULT_REGION)
export ES_SIGNING=1
export ES_SSL=1
export SNAPSHOT_BUCKET=
export SNAPSHOT_BUCKET_REGION=
export SNAPSHOT_NAME=
export DELETE_INDEX_FILTERS=[{"filtertype": "pattern", "kind": "prefix", "value": "logstash-"},{"filtertype": "age", "source": "name", "direction": "older", "timestring": "%Y.%m.%d", "unit": "days", "unit_count": "3"}]
export SNAPSHOT_INDEX_FILTERS=[]
export TEST_MODE=true


.PHONY: setup
setup: # Installs Python dependencies.
	pip install -r lambda/requirements.txt


.PHONY: test
test: # Runs the Lambda function locally.
	python3 lambda/main.py
