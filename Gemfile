# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'rake', require: false

group :development do
  gem 'byebug', platforms: :ruby
  gem 'rubocop'
end

group :test do
  gem 'bcrypt'
  gem 'minitest-spec-rails'
  gem 'rspec-rails'
end

group :docs do
  gem 'yard'
  gem 'yard-sitemap', '~> 1.0'
end

group :release do
  gem 'octokit'
end
