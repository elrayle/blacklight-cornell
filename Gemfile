source 'https://rubygems.org'
ruby "2.2.2"

gem 'rails', '4.2.1'
gem "dotenv-rails"
gem "dotenv-deployment"
gem 'appsignal'

# added for rails 4.
gem 'activerecord-session_store'
gem 'protected_attributes'

gem 'sqlite3'
gem 'savon', '~> 2.11.1'
gem 'parslet'
gem 'ultraviolet'
gem 'mysql'
gem 'yaml_db'
gem 'blacklight', '5.9'
gem 'blacklight_range_limit'
gem 'blacklight_unapi', :git => 'git@github.com:cul-it/blacklight-unapi', :branch => 'rails4'
gem 'kaminari', '0.15.0'

gem 'blacklight_google_analytics'
gem 'blacklight-hierarchy'
gem 'json'
gem 'httpclient'
gem 'haml'
gem 'haml-rails'
gem 'marc'
gem 'blacklight-marc'
gem 'rb-readline', '~> 0.4.2'
gem 'net-ldap'
#gem 'newrelic_rpm'
gem 'nokogiri'
gem 'rufus-scheduler'
gem 'addressable'

# Gems used only for assets and not required
# in production environments by default.
  gem 'sass-rails',   '~> 4.0'
  gem 'coffee-rails', '~> 4.0'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  #  gem 'therubyracer', '~> 0.10.2', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'

group :development, :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'cucumber-rails', :require => false # Set require = false to get rid of a warning message
  gem 'database_cleaner'
  gem 'webrat'
  gem 'guard-rspec'
  gem 'poltergeist'
  gem 'pry'
  gem 'pry-byebug'
  gem 'meta_request'
end
  
group :test do
  gem 'capybara'
  # Following two gems are following the setup proposed in the RoR tutorial
  # at http://ruby.railstutorial.org/chapters/static-pages#sec-advanced_setup
  gem 'rb-inotify'
  gem 'libnotify'
  # Spork support
  gem 'guard-spork', '0.3.2'
  gem 'spork', '0.9.0'
  gem 'webmock'
  gem 'vcr'
  gem 'capybara-email'
end

gem 'jquery-rails'
gem 'jquery-ui-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
 gem 'capistrano'
 gem 'capistrano-ext'
 gem 'rvm-capistrano', require: false

# To use debugger
# gem 'debugger'
gem 'unicode', :platforms => [:mri_18, :mri_19, :mri_20]
gem 'devise', '3.5.1'
gem 'devise-guests', '~> 0.3'
gem 'bootstrap-sass', '3.2'
gem 'font-awesome-rails' 
gem 'blacklight_cornell_requests',:git =>'git@github.com:cul-it/blacklight-cornell-requests.git', :branch => 'master'
gem 'borrow_direct', :git => 'git@github.com:jrochkind/borrow_direct.git'

gem 'bento_search'
gem 'celluloid'  # Required for bento_search multisearcher
# gem 'worldcat'
#gem 'rest_mollom', :git => 'https://github.com/hernan/rest_mollom.git'
gem 'mollom'
#gem 'blacklight-marc'
gem 'exception_notification'
gem 'hipchat'



# gem 'ld4l_virtual_collection', :git => 'git@github.com:ld4l/ld4l_virtual_collection.git', :branch => 'solr_integration'
gem 'ld4l_virtual_collection', :path => '/Users/elr37/Documents/__DEVELOPMENT__/__LD4L/at_solrizer/ld4l_virtual_collection_2015-08-19-1520'

gem 'rdf', '~> 1.1'
gem 'active-triples', '0.6.1'
gem 'active_triples-local_name'
# gem 'active_triples-solrizer', :git => 'git@github.com:ActiveTriples/active_triples-solrizer.git', :branch => 'modifiers_from_solrizer_gem'
gem 'active_triples-solrizer', :path => '/Users/elr37/Documents/__DEVELOPMENT__/__LD4L/at_solrizer/active_triples-solrizer'

# gem 'ld4l-foaf_rdf', '~> 0.0'
# gem 'ld4l-foaf_rdf', :git => 'git@github.com:ld4l/foaf_rdf.git', :branch => 'solr_integration'
gem 'ld4l-foaf_rdf', :path => '/Users/elr37/Documents/__DEVELOPMENT__/__LD4L/at_solrizer/foaf_rdf_2015-08-20-1630'

# gem 'ld4l-open_annotation_rdf', '~> 0.0'
# gem 'ld4l-open_annotation_rdf', :git => 'git@github.com:ld4l/open_annotation_rdf.git', :branch => 'solr_integration'
gem 'ld4l-open_annotation_rdf', :path => '/Users/elr37/Documents/__DEVELOPMENT__/__LD4L/at_solrizer/open_annotation_rdf_2015-08-20-1630'

gem 'doubly_linked_list', '~> 0.0'
# gem 'ld4l-ore_rdf', '~> 0.0'
# gem 'ld4l-ore_rdf', :git => 'git@github.com:ld4l/ore_rdf.git', :branch => 'solr_integration'
gem 'ld4l-ore_rdf', :path => '/Users/elr37/Documents/__DEVELOPMENT__/__LD4L/at_solrizer/ore_rdf_2015-06-24-1600'

# gem 'ld4l-works_rdf', :git => 'git@github.com:ld4l/works_rdf.git', :branch => 'master'
# gem 'ld4l-works_rdf', :git => 'git@github.com:ld4l/works_rdf.git', :branch => 'solr_integration'
gem 'ld4l-works_rdf', :path => '/Users/elr37/Documents/__DEVELOPMENT__/__LD4L/at_solrizer/works_rdf_2015-08-22-0900'


gem 'httparty'

group :development do
  # setup sqlite3 as the persistance triplestore for ActiveTriples
  # gem 'sqlite3'
  # gem 'rdf-do'
  # gem 'do_sqlite3'
  # # setup virtuoso as the persistance triplestore for ActiveTriples
  # gem 'rdf-virtuoso'
  # gem 'rdf-blazegraph'
end

group :profile do
  gem 'ruby-prof'
  # gem 'rdf-do'
  # gem 'do_sqlite3'
  # gem 'rdf-virtuoso'
  # gem 'rdf-blazegraph'
end

# setup blaze graph as the persistance triplestore for ActiveTriples
gem 'rdf-blazegraph'
