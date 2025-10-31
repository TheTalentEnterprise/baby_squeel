source 'https://rubygems.org'

# Load gemspec dependencies
gemspec

ar_version = ENV.fetch('AR', 'latest')

if ar_version == 'master'
  gem 'activerecord', github: 'rails/rails'
elsif ar_version == 'latest'
  gem 'activerecord'
else
  gem 'activerecord', ar_version
end

gem 'sqlite3', '~> 2.2'

ransack_version = ENV.fetch('RANSACK', 'latest')
if ransack_version == 'master'
  gem 'ransack', github: 'activerecord-hackery/ransack', require: false
else
  gem 'ransack', require: false
end

gem 'bump'

group :test do
  gem 'pry'
  gem 'simplecov'
  gem 'byebug'
end
