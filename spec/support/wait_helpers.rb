# frozen_string_literal: true

# spec/support/wait_helpers.rb
# Custom wait utilities on top of Capybara's built-in polling.
#
# RULE: never call sleep in a test. Always use Capybara matchers or these helpers.
# Capybara's default_max_wait_time already handles most async scenarios.
# These helpers cover cases Capybara can't handle natively.

module WaitHelpers
  # Wait until the browser has no pending AJAX requests.
  # Works for jQuery-based apps. Freshservice uses jQuery internally.
  #
  # WHY: Some actions (save ticket) trigger an XHR then update the DOM.
  # Capybara waits for DOM changes but doesn't know about in-flight XHRs.
  def wait_for_ajax(timeout: 10)
    Timeout.timeout(timeout) do
      loop do
        active = page.evaluate_script('jQuery.active').to_i
        break if active.zero?

        sleep 0.1
      end
    end
  rescue Timeout::Error
    raise "AJAX requests still pending after #{timeout}s"
  end

  # Wait until the current URL matches the given pattern.
  # Useful after a form submit that redirects (e.g. create ticket → show page).
  def wait_for_url(pattern, timeout: 10)
    Timeout.timeout(timeout) do
      loop do
        break if page.current_url.match?(pattern)

        sleep 0.1
      end
    end
  rescue Timeout::Error
    raise "URL did not match #{pattern} after #{timeout}s. Current: #{page.current_url}"
  end

  # Scroll an element into view before interacting.
  # Needed for sticky headers that can obscure elements in Selenium.
  def scroll_to(element)
    page.execute_script('arguments[0].scrollIntoView({block: "center"})', element.native)
  end

  # Dismiss any toast/flash notifications that may block other elements.
  def dismiss_flash
    find('.alert-close', wait: 3).click if page.has_css?('.alert-close', wait: 0)
  rescue Capybara::ElementNotFound
    nil
  end
end

RSpec.configure { |c| c.include WaitHelpers, :ui }
