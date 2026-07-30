require "rake/testtask"
begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  task :spec do
    warn "RSpec is not installed; run bundle install first."
    exit 1
  end
end
task default: :spec

desc "Build the contracts-rb gem"
task :build do
  sh "gem build contracts-rb.gemspec"
end
