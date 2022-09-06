require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'bump/tasks'

RSpec::Core::RakeTask.new(:spec)

Bump::Bump::BUMPS.each do |bump|
  desc "Increment #{bump} and release"
  task "release:#{bump}" => "bump:#{bump}" do
    # we can't just run this as a prereq, because gem_tasks
    # loads the version when rake loads
    Bundler.with_clean_env do
      sh 'bundle exec rake release'
    end
  end
end

task default: :spec
