source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '6.1.7.10'

# Remove this entry after Rails is updated further
gem 'concurrent-ruby', '1.3.4'

# Use sqlite3 as the database for Active Record
gem 'puma'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

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
gem "yard"

# Access AWS dynamo db
gem 'dynamoid'

# Access OpenSearch (with signed requests)
gem 'opensearch-ruby'
gem 'opensearch-aws-sigv4'

gem "whenever"

# Unlike in most of our projects, this is used in production (to set the node type)
gem 'dotenv-rails'

gem "openstax_path_prefixer", github: "openstax/path_prefixer"

gem "openstax_aws"

# More concise, one-liner logs (better for production)
gem "lograge"

gem 'sentry-raven'

gem 'nokogiri'

gem 'openstax_cnx'

gem "openstax_swagger", github: 'openstax/swagger-rails'

# CORS
gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  gem 'pry-rails'

  gem 'rspec-rails'
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
  gem 'listen'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen'
end
