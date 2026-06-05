# frozen_string_literal: true

# spec/support/api_context.rb
# Shared context for all API tests — included automatically via:
#   config.include_context 'with api client', :api

RSpec.shared_context 'with api client' do
  # Capture the last API response so the after(:each, :api) Allure hook
  # in spec_helper can attach it to failed test reports.
  let(:last_response) { nil }

  around(:each) do |example|
    example.run
    # Expose thread-local response (set by BaseClient#log_response) to the hook
    @last_response = Thread.current[:last_api_response]
    Thread.current[:last_api_response] = nil
  end
end
