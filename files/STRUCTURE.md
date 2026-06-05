# Freshservice TPCR — RSpec Project Structure
# =============================================
# Every folder exists for a reason. If an interviewer asks
# "why is X in Y?" you should have an answer.
# =============================================

freshservice_tpcr_tests/
│
├── Gemfile                        # Gem declarations with version constraints
├── Gemfile.lock                   # Locked dependency tree — commit this to git
│                                  # WHY: ensures every environment (local, CI, team)
│                                  # runs identical gem versions
│
├── .rspec                         # RSpec CLI default flags — applied on every run
│                                  # Contents: --require spec_helper --format documentation
│                                  #           --color --order random
│                                  # WHY random order: catches implicit test dependencies
│
├── .env                           # Local credentials — NEVER commit (add to .gitignore)
├── .env.example                   # Template with all required variable names, no values
│                                  # Commit this — documents what the project needs
│
├── .gitignore                     # Must include: .env, allure-results/, allure-report/,
│                                  #   vendor/, .bundle/, tmp/, *.log
│
├── Rakefile                       # Rake task definitions
│                                  # Tasks: rspec:smoke, rspec:regression, rspec:ui,
│                                  #        rspec:api, allure:generate, allure:open,
│                                  #        cleanup:test_data
│
├── Jenkinsfile                    # Declarative Jenkins pipeline
│                                  # Stages: Setup → Test → Report → Publish
│                                  # Reads BROWSER, ENV, TAG as job parameters
│
├── .rubocop.yml                   # RuboCop configuration
│                                  # Disable cops that conflict with test style
│                                  # (e.g. Metrics/BlockLength for describe blocks)
│
│
├── spec/                          # ALL test files live here — RSpec convention
│   │                              # File naming: *_spec.rb
│   │
│   ├── spec_helper.rb             # RSpec bootstrap — loaded by every spec via .rspec
│   │                              # Configures: RSpec globals, Capybara, Allure,
│   │                              #   rspec-retry, shared context auto-loading,
│   │                              #   before/after suite hooks
│   │
│   ├── support/                   # Auto-loaded helpers (via Dir.glob in spec_helper)
│   │   ├── capybara.rb            # Capybara driver registration (chrome, chrome_headless, firefox)
│   │   ├── allure.rb              # AllureRspec.configure block + screenshot on failure hook
│   │   ├── wait_helpers.rb        # Custom wait methods (wait_for_ajax, wait_for_url)
│   │   ├── session_helpers.rb     # Login helper, session switching for multi-user tests
│   │   └── shared_examples/
│   │       ├── api_crud.rb        # shared_examples 'a CRUD resource' — reused across all 4 entities
│   │       └── pagination.rb      # shared_examples 'a paginated list endpoint'
│   │
│   ├── ui/                        # UI/browser tests (require :js tag for Selenium driver)
│   │   │
│   │   ├── tickets/
│   │   │   ├── create_ticket_spec.rb      # Happy path + validation errors
│   │   │   ├── update_ticket_spec.rb      # Status transitions, field updates
│   │   │   ├── delete_ticket_spec.rb      # Delete + restore
│   │   │   └── ticket_linking_spec.rb     # Link ticket to problem (cross-entity)
│   │   │
│   │   ├── problems/
│   │   │   ├── create_problem_spec.rb
│   │   │   ├── problem_analysis_spec.rb   # Root cause, known error flag
│   │   │   └── problem_change_spec.rb     # Spawn change from problem
│   │   │
│   │   ├── changes/
│   │   │   ├── create_change_spec.rb
│   │   │   ├── change_approval_spec.rb    # Multi-user: submit → CAB approve
│   │   │   └── change_workflow_spec.rb    # Draft → Submitted → Implementation → Review
│   │   │
│   │   └── releases/
│   │       ├── create_release_spec.rb
│   │       ├── release_changes_spec.rb    # Add/remove changes from release
│   │       └── release_deploy_spec.rb     # Deploy → auto-close linked changes
│   │
│   └── api/                       # API tests — no browser, Selenium not needed
│       │                          # These run 10x faster than UI tests
│       │
│       ├── tickets/
│       │   ├── create_ticket_api_spec.rb  # POST /api/v2/tickets — all field combinations
│       │   ├── get_ticket_api_spec.rb     # GET single + list + pagination
│       │   ├── update_ticket_api_spec.rb  # PUT — partial update, status transitions
│       │   ├── delete_ticket_api_spec.rb  # DELETE + restore endpoint
│       │   └── ticket_notes_api_spec.rb   # POST /tickets/:id/notes
│       │
│       ├── problems/
│       │   ├── create_problem_api_spec.rb
│       │   ├── problem_analysis_api_spec.rb
│       │   └── problem_crud_api_spec.rb
│       │
│       ├── changes/
│       │   ├── create_change_api_spec.rb
│       │   ├── change_approvals_api_spec.rb   # GET/PUT approvals sub-resource
│       │   └── change_crud_api_spec.rb
│       │
│       └── releases/
│           ├── create_release_api_spec.rb
│           ├── release_build_api_spec.rb
│           └── release_crud_api_spec.rb
│
│
├── lib/                           # All non-test Ruby code — loaded by spec_helper
│   │                              # WHY separate from spec/: keeps test logic (spec/)
│   │                              # separate from support code (lib/)
│   │
│   ├── pages/                     # Site Prism page objects — one class per page
│   │   │                          # RULE: NO Capybara calls in spec files.
│   │   │                          # Specs call page methods; pages call Capybara.
│   │   │
│   │   ├── base_page.rb           # SitePrism::Page base — common helpers all pages share
│   │   │                          # (screenshot, wait_for_page_load, current_agent_email)
│   │   │
│   │   ├── login_page.rb          # /login — login form interactions
│   │   │
│   │   ├── tickets/
│   │   │   ├── ticket_list_page.rb    # /tickets — list, filter, search, pagination
│   │   │   ├── ticket_form_page.rb    # /tickets/new + edit form
│   │   │   └── ticket_show_page.rb    # /tickets/:id — detail view, status change, linking
│   │   │
│   │   ├── problems/              # Same pattern: list, form, show
│   │   ├── changes/               # Same pattern + approval_workflow_page.rb
│   │   └── releases/              # Same pattern
│   │
│   ├── sections/                  # Site Prism sections — reusable UI components
│   │   ├── header_toolbar.rb      # Top navigation bar
│   │   ├── activity_section.rb    # Activity timeline (appears on all entity show pages)
│   │   ├── relationship_panel.rb  # Linked tickets/problems/changes panel
│   │   └── approval_section.rb    # Approval workflow UI (changes + releases)
│   │
│   ├── api/                       # API client classes — one per entity
│   │   ├── base_client.rb         # HTTParty base: auth, base_uri, JSON headers,
│   │   │                          # standard error handling, response wrapper
│   │   ├── ticket_client.rb       # Ticket CRUD + notes + restore
│   │   ├── problem_client.rb      # Problem CRUD + analysis
│   │   ├── change_client.rb       # Change CRUD + approvals
│   │   └── release_client.rb      # Release CRUD + build/test phases
│   │
│   ├── data/                      # Test data factories — NOT Factory Bot (that's Rails)
│   │   ├── ticket_factory.rb      # build_ticket(overrides = {}) — default attrs + merge
│   │   ├── problem_factory.rb
│   │   ├── change_factory.rb
│   │   └── release_factory.rb
│   │                              # Pattern: factory returns a Hash, not an ORM object.
│   │                              # build_ticket(priority: 1, subject: Faker::Lorem.sentence)
│   │
│   └── helpers/                   # Pure Ruby utility modules
│       ├── auth_helper.rb         # encode_api_key, build_auth_header
│       ├── date_helper.rb         # scheduled_date formatting, due_date calculations
│       └── response_helper.rb     # parse_response, extract_id, assert_status
│
│
├── config/                        # Environment-specific configuration
│   │
│   ├── environments/
│   │   ├── staging.yml            # APP_URL, timeouts, feature flags for staging
│   │   ├── production.yml         # Read-only tests only (never write to prod)
│   │   └── local.yml              # Developer local environment overrides
│   │
│   └── capybara.rb                # Driver registrations (loaded by support/capybara.rb)
│                                  # Registers: :chrome, :chrome_headless,
│                                  #            :firefox, :firefox_headless
│                                  # Reads BROWSER env var to pick the active driver
│
│
├── schemas/                       # JSON Schema files for API response validation
│   ├── ticket_create_response.json
│   ├── ticket_show_response.json
│   ├── problem_create_response.json
│   ├── change_create_response.json
│   └── release_create_response.json
│                                  # WHY: Contract testing. If Freshservice removes a field
│                                  # from the V2 response, the schema test catches it before
│                                  # any downstream consumer hits a nil error.
│
│
├── allure-results/                # Generated by rspec run — contains raw JSON result files
│   └── (git-ignored)              # NEVER commit — regenerated on every run
│
├── allure-report/                 # Generated by `allure generate` CLI command
│   └── (git-ignored)              # HTML report — served by Jenkins Allure plugin
│
│
├── tmp/                           # Capybara screenshots on failure
│   └── screenshots/               # Allure attaches these to failed test entries
│
│
└── vendor/                        # Bundler local gem cache (bundle install --path vendor)
    └── (git-ignored)              # WHY: avoids polluting system Ruby gems in CI Docker container
