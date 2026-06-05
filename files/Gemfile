# frozen_string_literal: true

# ============================================================
# FRESHSERVICE TPCR — RSpec Automation Suite
# Ruby >= 3.2 required
# ============================================================
# WHY EACH GEM IS HERE — know this cold in interviews
# ============================================================

source 'https://rubygems.org'

ruby '>= 3.2'

# ─────────────────────────────────────────────
# CORE TEST FRAMEWORK
# ─────────────────────────────────────────────

# RSpec — BDD test framework. Not Minitest because we need:
#   - describe/context/it nesting for TPCR multi-state flows
#   - shared_examples for reusing CRUD assertions across entities
#   - metadata tagging (:smoke, :regression) for CI filtering
gem 'rspec', '~> 3.13'

# rspec-retry — retries flaky examples N times before marking failed.
# Critical for Selenium tests against a live SaaS app where
# network blips cause transient failures. Configured in spec_helper.
gem 'rspec-retry', '~> 0.6'

# ─────────────────────────────────────────────
# BROWSER AUTOMATION (UI LAYER)
# ─────────────────────────────────────────────

# Capybara — high-level browser interaction DSL that sits above Selenium.
# Provides auto-waiting (no sleep calls), finders, matchers.
# Works with multiple drivers: Selenium (real browser), Rack::Test (headless HTML).
gem 'capybara', '~> 3.40'

# selenium-webdriver — W3C WebDriver protocol client for Ruby.
# Drives Chrome/Firefox. Capybara delegates to this under the hood.
# WHY NOT chromedriver-helper: deprecated. selenium-webdriver 4.x
# includes automatic driver management via selenium-manager.
gem 'selenium-webdriver', '~> 4.22'

# site_prism — Page Object Model library built on top of Capybara.
# Gives you: element/elements/section/sections DSL, load validation,
# and async waiting. Keeps all CSS selectors out of spec files.
# WHY OVER raw Capybara in specs: if Freshservice renames a CSS class,
# you change ONE file (the page object), not every spec that touches it.
gem 'site_prism', '~> 4.0'

# webdrivers — DEPRECATED in favor of selenium-manager (built into selenium-webdriver 4.6+).
# Listed here as a comment so you can explain WHY it is NOT in the Gemfile.
# If you see it in older projects: it auto-downloaded chromedriver binaries.
# selenium-manager does the same natively now.
# gem 'webdrivers'  # DO NOT ADD — selenium 4.6+ handles this

# ─────────────────────────────────────────────
# API TESTING (API LAYER)
# ─────────────────────────────────────────────

# httparty — lightweight HTTP client. Include the module in your client class,
# configure base_uri and auth once, call .get/.post/.put/.delete as class methods.
# WHY OVER rest-client: rest-client's API is less explicit about response codes
# and has had security issues. httparty is actively maintained.
# WHY OVER faraday: faraday is better for middleware chains (retry, logging).
# For a standalone test project, httparty is simpler. See note below.
gem 'httparty', '~> 0.22'

# NOTE on faraday vs httparty:
# If this project grows to need:
#   - per-request retry with exponential backoff
#   - structured request/response logging middleware
#   - multiple adapters (Typhoeus for parallel requests)
# → switch to faraday. For current scope, httparty is sufficient.

# json_schemer — validates API responses against JSON Schema files.
# Enables contract testing: define the expected shape of every V2
# response in a .json file, assert the actual response matches it.
# Much more robust than checking individual fields manually.
gem 'json_schemer', '~> 2.3'

# ─────────────────────────────────────────────
# TEST DATA
# ─────────────────────────────────────────────

# faker — generates realistic random test data at runtime.
# Subject lines, names, emails, descriptions — never hardcoded.
# WHY: hardcoded data creates cross-test dependencies and breaks
# when the account already has a record with that exact name.
gem 'faker', '~> 3.3'

# ─────────────────────────────────────────────
# CONFIGURATION & ENVIRONMENT
# ─────────────────────────────────────────────

# dotenv — loads .env file into ENV at process start.
# Keeps credentials out of the codebase.
# In Jenkins: variables are injected by the pipeline; dotenv
# silently skips the missing .env file. Works transparently.
gem 'dotenv', '~> 3.1'

# ─────────────────────────────────────────────
# REPORTING
# ─────────────────────────────────────────────

# allure-rspec — Allure formatter for RSpec.
# Generates JSON result files in allure-results/.
# The Allure CLI (installed separately) converts these to HTML.
# WHY ALLURE over HTML formatter: Allure gives you:
#   - timeline view (parallel execution visibility)
#   - categories (product bugs vs infra failures)
#   - steps (sub-step breakdown per test)
#   - attachments (screenshots, API response bodies)
#   - trend graph across builds in Jenkins
gem 'allure-rspec', '~> 2.24'

# ─────────────────────────────────────────────
# UTILITIES
# ─────────────────────────────────────────────

# parallel_tests — runs spec files across N parallel processes.
# Splits files by rough execution time from previous runs.
# Each process gets an isolated Chrome instance.
# Reduces a 40-min suite to ~10 min with 4 workers.
gem 'parallel_tests', '~> 4.7'

# ─────────────────────────────────────────────
# DEVELOPMENT / DEBUG ONLY
# ─────────────────────────────────────────────

group :development do
  # pry — interactive Ruby debugger. `binding.pry` drops you into a REPL
  # mid-test for live inspection of page state, variables, responses.
  gem 'pry', '~> 0.14'
  gem 'pry-byebug', '~> 3.10'   # step/next/continue commands in pry

  # rubocop — Ruby static analysis / code style enforcer.
  # rubocop-rspec adds RSpec-specific cops (e.g. max nested contexts).
  gem 'rubocop', '~> 1.65', require: false
  gem 'rubocop-rspec', '~> 3.0', require: false
end
