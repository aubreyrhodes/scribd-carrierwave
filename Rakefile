require 'bundler/gem_tasks'
require 'rake'
require 'rspec/core/rake_task'
require 'cover_me'

desc "Run all specs"
RSpec::Core::RakeTask.new('spec')

task default: 'spec'

namespace :cover_me do
  
  desc "Generates and opens code coverage report."
  task :report do
    require 'cover_me'
    CoverMe.complete!
  end
  
end

task :spec do
  Rake::Task['cover_me:report'].invoke
end