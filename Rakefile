# frozen_string_literal: true

require 'rspec/core/rake_task'

# ── Individual entity suites ──────────────────────────────────────────────────
namespace :rspec do
  %w[tickets problems changes releases].each do |entity|
    RSpec::Core::RakeTask.new("ui:#{entity}") do |t|
      t.rspec_opts = '--tag ui'
      t.pattern    = "spec/ui/#{entity}/**/*_spec.rb"
    end

    RSpec::Core::RakeTask.new("api:#{entity}") do |t|
      t.rspec_opts = '--tag api'
      t.pattern    = "spec/api/#{entity}/**/*_spec.rb"
    end
  end

  # Full suites
  RSpec::Core::RakeTask.new(:ui)  { |t| t.pattern = 'spec/ui/**/*_spec.rb' }
  RSpec::Core::RakeTask.new(:api) { |t| t.pattern = 'spec/api/**/*_spec.rb' }

  # Tag-based
  RSpec::Core::RakeTask.new(:smoke) do |t|
    t.rspec_opts = '--tag smoke'
    t.pattern    = 'spec/**/*_spec.rb'
  end

  RSpec::Core::RakeTask.new(:regression) do |t|
    t.rspec_opts = '--tag ~smoke'
    t.pattern    = 'spec/**/*_spec.rb'
  end
end

# ── Allure tasks ──────────────────────────────────────────────────────────────
namespace :allure do
  desc 'Generate Allure HTML report from allure-results/'
  task :generate do
    sh 'allure generate allure-results -o allure-report --clean'
  end

  desc 'Open Allure report in browser'
  task :open do
    sh 'allure open allure-report'
  end

  desc 'Generate and open'
  task report: %i[generate open]
end

# ── Default ───────────────────────────────────────────────────────────────────
task default: 'rspec:smoke'
