source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'aws-sdk-sqs'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'facebook-messenger'
gem 'kaminari'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'rails', '~> 5.2.2'
gem 'rest-client'
gem 'sass-rails', '~> 5.0'
gem 'shoryuken'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'simple-rss'
gem "slack-notifier"
gem 'turbolinks', '~> 5'
gem 'twilio-ruby', '~> 5.18.0'
gem 'twitter'
gem 'uglifier', '>= 1.3.0'
gem "whatsapp"

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  gem 'guard-rspec', require: false
  gem 'rspec-rails'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
end
