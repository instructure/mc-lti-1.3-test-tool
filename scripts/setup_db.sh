#!/bin/bash

set -e

# Allow time for postgres to start
for i in {1..5}; do
  bundle exec rake db:migrate && break
  test $i -eq 5 && : "Failed to perform migrations" && exit 1
  sleep 1
done

echo "Testing if latest migration is reversible..."
bundle exec rake db:migrate:redo

echo "Resetting the PostgreSQL database using a schema load..."
bundle exec rake db:reset
