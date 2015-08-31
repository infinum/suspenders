require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

# TODO:       build :provide_deploy_script
module Suspenders
  class AppGenerator < Rails::Generators::AppGenerator
    class_option :database, type: :string, aliases: "-d", default: "postgresql",
      desc: "Configure for selected database (options: #{DATABASES.join("/")})"

    class_option :skip_turbolinks, type: :boolean, default: true,
      desc: "Skip turbolinks gem"

    class_option :skip_bundle, type: :boolean, aliases: "-B", default: true,
      desc: "Don't run bundle install"

    def finish_template
      invoke :suspenders_customization
      super
    end

    def suspenders_customization
      invoke :customize_gemfile
      invoke :setup_development_environment
      invoke :setup_test_environment
      invoke :setup_production_environment
      invoke :setup_staging_environment
      invoke :setup_secret_token
      invoke :create_suspenders_views
      invoke :configure_app
      invoke :setup_stylesheets
      invoke :copy_miscellaneous_files
      invoke :remove_routes_comment_lines
      invoke :setup_git
      invoke :setup_database
      invoke :setup_segment
      invoke :setup_bundler_audit
      invoke :setup_spring
      invoke :outro
    end

    def customize_gemfile
      build :replace_gemfile
      build :set_ruby_to_version_being_used
      bundle_command 'install'
    end

    def setup_database
      say 'Setting up database'

      if 'postgresql' == options[:database]
        build :use_postgres_config_template
      end

      build :create_database
    end

    def setup_development_environment
      say 'Setting up the development environment'
      build :raise_on_delivery_errors
      build :set_test_delivery_method
      build :raise_on_unpermitted_parameters
      build :provide_setup_script
      build :provide_dev_prime_task
      build :configure_generators
      build :configure_i18n_for_missing_translations
    end

    def setup_test_environment
      say 'Setting up the test environment'
      build :set_up_factory_girl_for_rspec
      build :generate_rspec
      build :configure_rspec
      build :configure_background_jobs_for_rspec
      build :enable_database_cleaner
      build :configure_spec_support_features
      build :configure_i18n_for_test_environment
      build :configure_i18n_tasks
      build :configure_action_mailer_in_specs
    end

    def setup_production_environment
      say 'Setting up the production environment'
      build :configure_newrelic
      build :configure_smtp
      build :configure_rack_timeout
      build :enable_rack_canonical_host
      build :enable_rack_deflater
      build :setup_asset_host
    end

    def setup_staging_environment
      say 'Setting up the staging environment'
      build :setup_staging_environment
    end

    def setup_secret_token
      say 'Moving secret token out of version control'
      build :setup_secret_token
    end

    def create_suspenders_views
      say 'Creating suspenders views'
      build :create_partials_directory
      build :create_shared_flashes
      build :create_shared_javascripts
      build :create_application_layout
    end

    def configure_app
      say 'Configuring app'
      build :configure_action_mailer
      build :configure_active_job
      build :configure_time_formats
      build :configure_simple_form
      build :disable_xml_params
      build :fix_i18n_deprecation_warning
      build :setup_default_rake_task
      build :configure_puma
    end

    def setup_stylesheets
      say 'Set up stylesheets'
      build :setup_stylesheets
    end

    def setup_git
      say 'Initializing git'
      invoke :setup_gitignore
      invoke :init_git
    end

    def setup_segment
      say 'Setting up Segment'
      build :setup_segment
    end

    def setup_gitignore
      build :gitignore_files
    end

    def setup_bundler_audit
      say "Setting up bundler-audit"
      build :setup_bundler_audit
    end

    def setup_spring
      say "Springifying binstubs"
      build :setup_spring
    end

    def init_git
      build :init_git
    end

    def copy_miscellaneous_files
      say 'Copying miscellaneous support files'
      build :copy_miscellaneous_files
    end

    def remove_routes_comment_lines
      build :remove_routes_comment_lines
    end

    def outro
      say 'Congratulations! You just pulled our suspenders.'
      say "Remember to run 'rails generate airbrake' with your API key."
    end

    private

    def get_builder_class
      Suspenders::AppBuilder
    end

    def using_active_record?
      !options[:skip_active_record]
    end
  end
end
