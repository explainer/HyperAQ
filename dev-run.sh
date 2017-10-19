#!/bin/bash
#
rm log/*.log

crontab -r > /dev/null
touch lib/tasks/crontab
rm lib/tasks/crontab

bundle install
sh dev-bounce-db.sh
# sh dev-start.sh 
rails s
