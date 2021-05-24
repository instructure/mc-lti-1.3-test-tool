# mc-lti-1.3-test-tool
Modified version of lti-1.3-test-tool which is a tool to stub a LTI tool

This was taken from https://gerrit.instructure.com/plugins/gitiles/lti-1.3-test-tool/ and modified to run without a virtual machine dependency and run it through docker-composer only, while the original version used dinghy and a VM vendor to run in MacOS.

docker-compose build --pull
docker-compose run --rm web bundle exec rake db:create db:migrate db:seed
docker-compose up -d
