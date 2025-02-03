#!/bin/bash

watch 'docker ps -a --format "table {{.Names}}\t{{.Status}}"'