# frozen_string_literal: true

# spec/spec_helper.rb
# ============================================================
# RSpec bootstrap — loaded before every spec via .rspec flag:
#   --require spec_helper
#
# WHAT GOES HERE vs NOT HERE:
#   YES: RSpec global config, gem require order, auto-loading support files,
#        suite-level before/after hooks, formatter setup
#   NO:  Rails env, database config, ActiveRecord — this is NOT a Rails app
#        Any test-specific logic — that belongs in support/ or the spec itself
# ============================================================

require 'bundler/setup'

# Core gems — order matters
require 'rspec'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'site_prism'
require 'httparty'
require 'faker'
require 'dotenv'
require 'allure-rspec'
require 'json_schemer'

# Load .env file if present (local dev).
# In Jenkins: variables are injected by the pipeline — dotenv skips gracefully.
Dotenv.load('.env')

# Auto-load all support files.
# WHY Dir.glob over individual require: adding a new support file
# doesn't require editing spec_helper — it's picked up automatically.
Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }

# Auto-load all lib files (page objects, API clients, helpers, factories)
Dir[File.join(File.dirname(__dir__), 'lib', '**', '*.rb')].each { |f| require f }

# ─────────────────────────────────────────────
# ALLURE CONFIGURATION
# ─────────────────────────────────────────────
AllureRspec.configure do |config|
  config.results_directory     = 'allure-results'
  config.clean_results_directory = true           # Start fresh on every run
  config.logging_level         = Logger::WARN

  # Environment properties appear on the Allure Overview page.
  # Useful when debugging which environment a CI run targeted.
  config.environment_properties = {
    App_URL:     ENV.fetch('APP_URL', 'not set'),
    Browser:     ENV.fetch('BROWSER', 'chrome_headless'),
    Environment: ENV.fetch('TEST_ENV', 'staging'),
    Ruby_version: RUBY_VERSION
  }

  # Link test cases to Freshrelease/Jira tickets by pattern in test name.
  # Example: it 'creates a ticket [TC-123]' will render as a clickable link.
  config.link_tms_pattern       = "https://yourcompany.freshrelease.com/issues/{}"
  config.link_issue_pattern     = "https://yourcompany.atlassian.net/browse/{}"
end

# ─────────────────────────────────────────────
# RSPEC GLOBAL CONFIGURATION
# ─────────────────────────────────────────────
RSpec.configure do |config|

  # ── Formatter ──────────────────────────────
  # AllureRspecFormatter writes JSON to allure-results/.
  # Documentation formatter prints to terminal.
  # Both run simultaneously.
  config.formatter = AllureRspecFormatter

  # ── Run order ──────────────────────────────
  # Random order on each run catches implicit test dependencies
  # (test B only passes because test A ran first and created data).
  # Seed is printed — use `rspec --seed <N>` to reproduce a specific order.
  config.order = :random
  Kernel.srand config.seed

  # ── Mocking ────────────────────────────────
  config.mock_with :rspec do |mocks|
    # Prevents mocking methods that don't exist on the real class.
    # Catches typos in method names early.
    mocks.verify_partial_doubles = true
  end

  # ── Shared context auto-inclusion ──────────
  # Any describe/context block tagged with a known key automatically
  # gets the matching shared context included.
  # Add patterns here as the suite grows.
  config.include_context 'with authenticated session', :ui
  config.include_context 'with api client',            :api

  # ── rspec-retry ────────────────────────────
  # Retry flaky examples up to 2 times before marking as failed.
  # Applies only to :js (Selenium) examples — API tests should never be flaky.
  # retry_callback logs the retry attempt to Allure as a warning step.
  config.around(:each, :js) do |example|
    example.run_with_retry(
      retry:          2,
      retry_wait:     2,
      retry_callback: proc { |ex, n| warn "Retrying '#{ex.description}' (attempt #{n})" }
    )
  end

  # ── Screenshot on UI failure ───────────────
  # Attached to the Allure report as an image artifact.
  # Only fires for examples that use the Capybara driver (:js tag).
  config.after(:each, :js) do |example|
    next unless example.exception

    screenshot_name = "#{example.full_description.gsub(/\s+/, '_')[0..80]}_FAILED"
    Allure.add_attachment(
      name:   screenshot_name,
      source: page.save_screenshot("tmp/screenshots/#{screenshot_name}.png"),
      type:   Allure::ContentType::PNG,
      test_temp: false
    )
  end

  # ── API response logging on failure ────────
  # Attaches the last API response body to Allure when an API test fails.
  # Saves hours during CI failure triage.
  config.after(:each, :api) do |example|
    next unless example.exception && defined?(@last_response)

    Allure.add_attachment(
      name:   'Last API response',
      source: @last_response.to_s,
      type:   Allure::ContentType::JSON
    )
  end

  # ── Suite-level hooks ──────────────────────
  config.before(:suite) do
    # Verify required environment variables are present before any test runs.
    # Fail loudly with a clear message rather than a cryptic nil error mid-suite.
    required_vars = %w[APP_URL FS_API_KEY FS_DOMAIN]
    missing = required_vars.reject { |v| ENV[v] }
    raise "Missing required env vars: #{missing.join(', ')}. See .env.example" if missing.any?
  end

  config.after(:suite) do
    # Optionally: invoke a cleanup task here to delete any test data
    # that leaked due to a mid-run crash. Use a known test data prefix.
    # TestDataCleanup.run! if ENV['CLEANUP_AFTER_SUITE'] == 'true'
  end
end
