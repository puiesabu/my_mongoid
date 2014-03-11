require "bundler/gem_tasks"

task :spec do 
  system "rspec"
end

require 'coveralls/rake/task'
Coveralls::RakeTask.new
task :test_with_coveralls => [:spec,  'coveralls:push']
