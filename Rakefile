require "bundler/gem_tasks"
require "rspec/core/rake_task"

require "./examples/lemma_verification"

RSpec::Core::RakeTask.new(:spec)

desc "perform verification tests"
task :verify do
  Noam::LemmaVerification.run
end

task :default => :spec
