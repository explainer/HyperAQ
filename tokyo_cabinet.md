Jan Biedermann @janbiedermann Oct 21 12:26
Hi, for improved performance in development environment you can try this:
apt-get install libtokyocabinet-dev
or brew install tokyo-cabinet on macOS
then in your Gemfile:
group :development do
  gem 'tokyocabinet'
end
gem 'sprockets', git: 'https://github.com/janbiedermann/sprockets', branch: '3.x_perf_proper_mega'
then
bundle update
then in your config/development.rb
  # signature: TokyoStore.new(root_dir, max_entries, logger)
  # root_dir: directory to put the database file in, another TokyoStore needs another directory
  # max_entries: maximun entries in the database (NOT size in MB)
  # logger: the logger
  config.assets.configure do |env|
    env.cache = Sprockets::Cache::TokyoStore.new(
      "#{env.root}/tmp/cache/",
      10000,
      env.logger
    )
  end
If you try, tell me how it behaves on the pi, if it improves things for you. It implements a totally new sprockets caching thing and fixes a sprockets performance issue. This affects mostly development environment.
alternativly, if you ruby on the pi has gdbm and you are not confortable tih tokyocabinet, you can try GdbmStore instead of TokyoStore an then you need tokyocabinet.
It loads the cache in ram at startup and print a little statistic about cache usage on the disk, you can then adjust that number '10000' to suit your needs, mine currently has 4790 items.

Ken Burgett @explainer 09:39
@janbiedermann I just saw this note. It looks interesting. I will give it a try on the pi and report, but first, a try on my dev box.

Jan Biedermann @janbiedermann 09:41
oh, great, but things improved in between, new config is:
  config.assets.configure do |env|
    env.cache = Sprockets::Cache::TokyoStore.new(
      "#{env.root}/tmp/cache/",
      25000,
      env.logger
    )
    env.check_modified_paths = [Rails.root.join('app','hyperloop'), Rails.root.join('app', 'assets')]
  end

Ken Burgett @explainer 09:41
@janbiedermann OK, I will use the new stuff :smiley:
_
 
