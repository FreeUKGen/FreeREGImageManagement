FreeregImageManagement::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  if config.respond_to?(:action_mailer)
    config.action_mailer.raise_delivery_errors = false
  end

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
  config.serve_static_files = true

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
  config.assets.raise_runtime_errors = true
  config.assets.compile = true
  # Raise exception on mass assignment protection for Active Record models


  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)

  #where to store the collections PlaceChurch
  config.mongodb_collection_temp = File.join(Rails.root,'tmp')
  #Where the collections are stored
  config.mongodb_collection_location = File.join(Rails.root,'db','collections')
  # Date of dataset used
  config.dataset_date = "9 November 2014"
  config.imagedirectory = FreeregImageManagement::MongoConfig['imagedirectory']
  config.website = FreeregImageManagement::MongoConfig['website']
  config.application_website = FreeregImageManagement::MongoConfig['application_website']
  config.image_server_access =  FreeregImageManagement::MongoConfig['image_server_access']
  config.backup_directory = FreeregImageManagement::MongoConfig['backup_directory']
  config.github_issues_login = FreeregImageManagement::MongoConfig['github_issues_login']
  config.github_issues_password = FreeregImageManagement::MongoConfig['github_issues_password']
  config.github_issues_repo = FreeregImageManagement::MongoConfig['github_issues_repo']
  config.our_secret_key = FreeregImageManagement::MongoConfig['our_secret_key']
  config.eager_load = false
end
