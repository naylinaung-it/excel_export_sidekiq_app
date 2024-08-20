# Use this file to easily define all of your cron jobs.
# Clear cron: crontab -r
# Cron list: crontbab -l
# Update cron: bundle exec whenever --update-crontab
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron.log"
env :PATH, ENV['PATH']
set :output, "./log/cron.log"

every 1.minutes do
    runner "Product.test_method"
end



# Learn more: http://github.com/javan/whenever
