#!/bin/bash
# This script tests if the consultms service correctly handles proxy headers.
curl -i -X POST -H "X-Forwarded-Proto: https" -H "Content-Type: application/json" -d '{"email":"admin","password":"admin"}' http://192.168.0.153:6680/springboot-crud-rest-consultms/authenticate
