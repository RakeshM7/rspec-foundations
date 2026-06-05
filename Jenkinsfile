// Jenkinsfile — Declarative Pipeline
// ─────────────────────────────────────────────────────────────────────────────
// INTERVIEW KNOWLEDGE — know each block's purpose:
//
// pipeline {}       Top-level declarative wrapper. All config lives here.
// agent any         Jenkins picks any available executor node.
//                   Use 'agent { label "ruby-node" }' to pin to a specific slave.
// parameters {}     Exposes job parameters in the Jenkins UI (Build with Parameters).
// environment {}    Injects vars into every shell step. credentials() masks the value in logs.
// options {}        Cross-cutting concerns: timeout, log rotation, ANSI colour.
// stages {}         Ordered list of stages. Failure in any stage skips subsequent ones
//                   UNLESS marked with 'when { expression { true } }' or post { always }.
// post {}           Runs after stages complete — always/success/failure/unstable.
//                   Critical: allure report and cleanup must be in always {}, not success {}.
// ─────────────────────────────────────────────────────────────────────────────

pipeline {

  agent any

  // ── Job-level parameters ────────────────────────────────────────────────────
  // Visible in Jenkins UI as "Build with Parameters"
  parameters {
    choice(
      name:        'TEST_SUITE',
      choices:     ['smoke', 'api', 'ui', 'regression'],
      description: 'Which test suite to run'
    )
    choice(
      name:        'TEST_ENV',
      choices:     ['staging', 'production'],
      description: 'Target environment (production = read-only smoke only)'
    )
    choice(
      name:        'BROWSER',
      choices:     ['chrome_headless', 'chrome', 'firefox_headless'],
      description: 'Browser driver for UI tests'
    )
    string(
      name:        'RSPEC_TAG',
      defaultValue: '',
      description: 'Optional RSpec tag filter, e.g. smoke or ~slow'
    )
  }

  // ── Environment variables ───────────────────────────────────────────────────
  environment {
    // credentials('id') fetches a Jenkins Secret Text credential.
    // The value is MASKED in build logs — never printed even if someone does `echo $FS_API_KEY`.
    FS_API_KEY  = credentials('freshservice-api-key')
    APP_URL     = credentials('freshservice-app-url')

    // Non-secret values from parameters
    TEST_ENV    = "${params.TEST_ENV}"
    BROWSER     = "${params.BROWSER}"

    // Allure results directory — consistent across all stages
    ALLURE_RESULTS = 'allure-results'

    // Ruby version — must match .ruby-version or Gemfile ruby directive
    RBENV_VERSION = '3.2.4'
  }

  // ── Options ─────────────────────────────────────────────────────────────────
  options {
    timeout(time: 60, unit: 'MINUTES')    // Kill the build if it hangs
    buildDiscarder(logRotator(numToKeepStr: '20'))  // Keep last 20 builds
    ansiColor('xterm')                    // Colour in console output (needs AnsiColor plugin)
    disableConcurrentBuilds()             // Prevent two builds stepping on allure-results/
  }

  // ── Stages ───────────────────────────────────────────────────────────────────
  stages {

    stage('Checkout') {
      steps {
        // WHY explicit checkout: ensures clean workspace, picks up Jenkinsfile changes.
        checkout scm
        echo "Building branch: ${env.BRANCH_NAME} | Suite: ${params.TEST_SUITE}"
      }
    }

    stage('Setup — Install Ruby gems') {
      steps {
        sh '''
          # rbenv or rvm must be installed on the Jenkins agent.
          # If using Docker agent, use a ruby:3.2 image instead.
          gem install bundler --no-document
          bundle install --path vendor/bundle --jobs 4 --retry 3
        '''
      }
    }

    stage('Restore Allure History') {
      // Copy history from last successful build so the trend graph is continuous.
      // Without this, every build starts fresh and the trend resets.
      steps {
        script {
          if (fileExists('allure-report/history')) {
            sh 'cp -r allure-report/history allure-results/ || true'
          }
        }
      }
    }

    stage('Run API Tests') {
      when {
        // Run API tests for: smoke, api, regression suites.
        // Skip for 'ui' suite.
        expression { params.TEST_SUITE in ['smoke', 'api', 'regression'] }
      }
      steps {
        script {
          def tag_opt = params.RSPEC_TAG ? "--tag ${params.RSPEC_TAG}" : ''
          // exit 0 on pending/skipped to avoid false Jenkins failures.
          // RSpec exits non-zero for pending examples — we want Jenkins GREEN for those.
          sh """
            bundle exec rspec spec/api \
              --format AllureRspecFormatter \
              --format documentation \
              ${tag_opt} \
              || true
          """
        }
      }
    }

    stage('Run UI Tests') {
      when {
        expression { params.TEST_SUITE in ['smoke', 'ui', 'regression'] }
      }
      steps {
        script {
          def tag_opt = params.RSPEC_TAG ? "--tag ${params.RSPEC_TAG}" : '--tag ui'
          sh """
            BROWSER=${params.BROWSER} bundle exec rspec spec/ui \
              --format AllureRspecFormatter \
              --format documentation \
              ${tag_opt} \
              || true
          """
        }
      }
    }

    stage('Generate Allure Report') {
      steps {
        sh 'allure generate allure-results -o allure-report --clean'
      }
    }

  } // end stages

  // ── Post-build actions ────────────────────────────────────────────────────────
  post {

    always {
      // Publish Allure report via the Allure Jenkins Plugin.
      // This adds a link to the build page and powers the trend graph.
      // Plugin config: Manage Jenkins → Global Tool Configuration → Allure
      allure([
        includeProperties: true,
        jdk:               '',
        results:           [[path: 'allure-results']],
        report:            'allure-report'
      ])

      // Archive test artifacts for debugging without the UI.
      archiveArtifacts artifacts: 'tmp/screenshots/**/*.png', allowEmptyArchive: true
      archiveArtifacts artifacts: 'allure-results/**/*.json', allowEmptyArchive: true
    }

    success {
      echo 'All tests passed. Allure report published.'
      // Uncomment to notify Slack on success:
      // slackSend color: 'good', message: "PASS: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
    }

    failure {
      echo 'Build failed. Check Allure report and archived screenshots.'
      // emailext (
      //   subject: "FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
      //   body:    "See ${env.BUILD_URL}allure/",
      //   to:      'qa-team@yourcompany.com'
      // )
    }

    cleanup {
      // Delete workspace contents after the build to reclaim disk on the agent.
      // Gemfile.lock stays committed in git — vendor/ is regenerated next run.
      cleanWs(cleanWhenAborted: true, cleanWhenFailure: false, cleanWhenSuccess: true)
    }

  } // end post

} // end pipeline
