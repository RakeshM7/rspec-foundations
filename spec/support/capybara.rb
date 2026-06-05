# frozen_string_literal: true

# spec/support/capybara.rb
# ─────────────────────────────────────────────────────────────────────────────
# Driver registration and Capybara global defaults.
#
# WHY register named drivers instead of using the defaults?
# Named drivers let you switch via BROWSER env var without changing code.
# CI sets BROWSER=chrome_headless; local dev sets BROWSER=chrome (headed).
# ─────────────────────────────────────────────────────────────────────────────

require 'capybara'
require 'capybara/rspec'
require 'selenium-webdriver'

# ── Headless Chrome (default for CI) ─────────────────────────────────────────
Capybara.register_driver :chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')   # new headless mode (Chrome 112+)
  options.add_argument('--no-sandbox')     # required in Docker/Jenkins agents
  options.add_argument('--disable-dev-shm-usage') # prevents /dev/shm OOM in containers
  options.add_argument('--window-size=1440,900')
  options.add_argument('--disable-gpu')
  # Disable infobars and notifications that can obscure UI elements
  options.add_argument('--disable-notifications')
  options.add_experimental_option('excludeSwitches', ['enable-automation'])

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# ── Headed Chrome (local debugging) ──────────────────────────────────────────
Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--window-size=1440,900')
  options.add_argument('--disable-notifications')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# ── Headless Firefox (alternative) ───────────────────────────────────────────
Capybara.register_driver :firefox_headless do |app|
  options = Selenium::WebDriver::Firefox::Options.new
  options.add_argument('-headless')

  Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
end

# ── Global Capybara settings ─────────────────────────────────────────────────
Capybara.configure do |config|
  # Pick driver from BROWSER env var, default to chrome_headless.
  # This is how Jenkins selects headless without any code change.
  config.default_driver    = (ENV.fetch('BROWSER', 'chrome_headless')).to_sym
  config.javascript_driver = config.default_driver

  config.app_host         = ENV.fetch('APP_URL', 'https://yourdomain.freshservice.com')
  config.default_max_wait_time = 10   # seconds — Capybara polls until element appears
  config.ignore_hidden_elements    = true
  config.automatic_reload          = true

  # Save screenshots to tmp/screenshots/ (Allure picks these up in after hook)
  config.save_path = 'tmp/screenshots'
end

# ── Shared contexts ───────────────────────────────────────────────────────────
# Tagged with :ui — included automatically via spec_helper config.include_context
RSpec.shared_context 'with authenticated session' do
  # Log in once before the first example in this context group.
  # Using before(:context) keeps us from re-logging-in per test (slow).
  # CAVEAT: browser state is shared — reset page state in before(:each) instead.
  before(:context) do
    @login_page = Pages::LoginPage.new
    @login_page.load
    @login_page.login_as(
      email:    ENV.fetch('AGENT_EMAIL'),
      password: ENV.fetch('AGENT_PASSWORD')
    )
  end

  after(:context) { Capybara.reset_sessions! }

  # Ensure fresh page state per example without a full re-login.
  before(:each) { Capybara.current_session.driver.browser.manage.delete_all_cookies rescue nil }
end
