source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.2'
# Use sqlite3 as the database for Active Record
gem 'puma', '~> 4.3'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Gives 200 OK from /ping
gem 'openstax_healthcheck'

# For installing secrets on deploy
gem "aws-sdk-ssm"

# For indexing releases
gem "aws-sdk-s3"

# For accessing dynamoDB tables
gem "aws-sdk-dynamodb"

# Managing index job queues
gem "aws-sdk-sqs"

# Versioned API tools
gem "versionist"

# https://github.com/lsegal/yard/security/advisories/GHSA-xfhh-rx56-rxcr
gem "yard", ">= 0.9.20"

# Access AWS dynamo db
gem 'dynamoid'

# Access OpenSearch (with signed requests)
gem 'opensearch-ruby'
gem 'opensearch-aws-sigv4'

gem "whenever"

# Unlike in most of our projects, this is used in production (to set the node type)
gem 'dotenv-rails'

gem "openstax_path_prefixer", github: "openstax/path_prefixer", ref: "b6d8f45d8"

gem "openstax_aws", github: "openstax/aws-ruby", ref: 'a123f496e8'

# More concise, one-liner logs (better for production)
gem "lograge"

gem 'sentry-raven'

gem 'nokogiri'

gem 'openstax_cnx', github: 'openstax/cnx-ruby', ref: 'ad1bef4'

gem "openstax_swagger", github: 'openstax/swagger-rails', ref: 'c88e569'

# CORS
gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  gem 'pry-rails'

  gem 'rspec-rails', '~> 3.8'
  gem 'rspec-json_expectations'

  # Stubs HTTP requests
  gem 'webmock'

  # Records HTTP requests
  gem 'vcr'

  gem 'whenever-test'

  gem 'aws-sdk-opensearchservice'
  gem 'aws-sdk-autoscaling'

  # For getting information about AWS users in tests
  gem 'aws-sdk-iam'

  gem 'rubocop'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
