source 'https://rubygems.org'

# Debugger
gem 'pry'

# Coveralls
gem 'coveralls', require: false

# Testing in development and test environments
group :test do
  gem "rspec", "~> 3.0.0.beta1"

	if ENV["CI"]
	  require "coveralls"
	  Coveralls.wear! do
	    add_filter "spec"
	  end
	end
end

# Specify your gem's dependencies in my_mongoid.gemspec
gemspec
