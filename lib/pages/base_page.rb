# frozen_string_literal: true

# lib/pages/base_page.rb
# ─────────────────────────────────────────────────────────────────────────────
# All page objects inherit from this.
# Provides: common elements present on every page, shared helper methods.
#
# WHY SitePrism::Page over plain Capybara?
# SitePrism gives us:
#   1. element/elements DSL — named accessors for DOM elements
#   2. section/sections DSL — reusable sub-page components
#   3. load_validation — verify the correct page loaded before interacting
#   4. loaded? — synchronous check usable in expectations
# ─────────────────────────────────────────────────────────────────────────────

require 'site_prism'

module Pages
  class BasePage < SitePrism::Page
    # Elements present on every authenticated Freshservice page
    element :page_title,    'h1.page-title, .module-header h1'
    element :flash_message, '.flash-notice, .notice, [data-notification]'
    element :spinner,       '.loading-spinner, .preloader'
    element :user_menu,     '[data-testid="user-menu"], .user-dropdown'

    # ── Helpers ──────────────────────────────────────────────────────────────

    # Wait for the loading spinner to disappear before interacting.
    # Freshservice uses spinners heavily between page transitions.
    def wait_for_page_ready(timeout: 10)
      has_no_css?('.loading-spinner', wait: timeout)
      has_no_css?('.preloader', wait: timeout)
    end

    # Click an element that may be off-screen in headless Chrome.
    def safe_click(element)
      page.execute_script('arguments[0].scrollIntoView({block: "center"})', element.native)
      element.click
    end

    # Select from a Freshservice dropdown (not a native <select> — it's custom).
    # Pattern: click trigger → wait for list → click option by text.
    def select_from_dropdown(trigger_selector, option_text)
      find(trigger_selector).click
      find('.dropdown-menu .dropdown-item, [role="option"]', text: option_text, wait: 5).click
    end

    # Check if a flash/toast message with given text is visible.
    def has_success_message?(text)
      has_css?('.flash-notice, .success-toast', text: text, wait: 5)
    end
  end
end
