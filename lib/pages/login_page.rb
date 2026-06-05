# frozen_string_literal: true

# lib/pages/login_page.rb

module Pages
  class LoginPage < BasePage
    set_url '/login'

    # load_validation: SitePrism calls this after load to confirm the correct page rendered.
    # If the element isn't found within default_max_wait_time, it raises SitePrism::NotLoadedError.
    load_validation { has_css?('#agent_email, input[name="email"]') }

    element :email_field,    '#agent_email, input[name="email"]'
    element :password_field, '#agent_password, input[name="password"]'
    element :login_button,   'input[type="submit"], button[type="submit"]'
    element :error_message,  '.error-msg, .alert-danger'

    # High-level action used in before(:context) of the shared authenticated context.
    def login_as(email:, password:)
      email_field.set(email)
      password_field.set(password)
      login_button.click
      # Wait for redirect away from /login — confirms successful auth.
      wait_until { !current_url.include?('/login') }
    end
  end
end
