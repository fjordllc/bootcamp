#!/bin/sh

set -eux

bin/setup
bin/rails db:test:prepare
