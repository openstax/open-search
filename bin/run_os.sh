#!/bin/bash

docker run -p 9200:9200 -p 9300:9300 \
           -v open_search:/usr/share/opensearch/data \
           -e "discovery.type=single-node" \
           opensearchproject/opensearch:2.7
