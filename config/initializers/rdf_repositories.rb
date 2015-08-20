require 'rdf/blazegraph'

def configure_repositories
  ActiveTriples::Repositories.clear_repositories!

  @metadata_localhost_callback_lambda = lambda do |metadata_items|
    # MetadataCallback.get_localhost_metadata_from_marcxml(metadata_items)
    MetadataCallback.get_cornell_metadata_from_solr(metadata_items)
  end

  @metadata_cornell_catalog_callback_lambda = lambda do |metadata_items|
    # MetadataCallback.get_cornell_metadata_from_marcxml(metadata_items)
    MetadataCallback.get_cornell_metadata_from_solr(metadata_items)
  end

  @metadata_stanford_catalog_callback_lambda = lambda do |metadata_items|
    MetadataCallback.get_stanford_metadata_from_marcxml(metadata_items)
  end

  @metadata_harvard_catalog_callback_lambda = lambda do |metadata_items|
    MetadataCallback.get_harvard_metadata_from_XXX(metadata_items)
  end

  @metadata_cornell_vivo_callback_lambda = lambda do |metadata_items|
    MetadataCallback.get_cornell_vivo_metadata(metadata_items)
  end

  @metadata_oclc_callback_lambda = lambda do |metadata_items|
    MetadataCallback.get_oclc_metadata(metadata_items)
  end

  @metadata_default_callback_lambda = lambda do |metadata_items|
    MetadataCallback.attempt_generic_metadata_extraction(metadata_items)
  end

  Ld4lVirtualCollection::Engine.configure do |config|
    config.register_metadata_callback( "localhost",                      @metadata_localhost_callback_lambda )
    config.register_metadata_callback( "newcatalog.library.cornell.edu", @metadata_cornell_catalog_callback_lambda )
    config.register_metadata_callback( "searchworks.stanford.edu",       @metadata_stanford_catalog_callback_lambda )
    config.register_metadata_callback( "id.lib.harvard.edu",             @metadata_harvard_catalog_callback_lambda )
    config.register_metadata_callback( "vivo.cornell.edu",               @metadata_cornell_vivo_callback_lambda )
    config.register_metadata_callback( "www.worldcat.org",               @metadata_oclc_callback_lambda )
    config.register_default_metadata_callback(                           @metadata_default_callback_lambda )
  end

  if Rails.env.development?
    ActiveTriples::Repositories.add_repository :default, RDF::Blazegraph::Repository.new("http://localhost:9999/bigdata/sparql")
    # ActiveTriples::Repositories.add_repository :default, RDF::DataObjects::Repository.new(Rails.configuration.triplestore.default_repository)
  elsif Rails.env.test?
    # ActiveTriples::Repositories.add_repository :default, RDF::Repository.new
    ActiveTriples::Repositories.add_repository :default, RDF::Blazegraph::Repository.new("http://localhost:9999/bigdata/sparql")
  # elsif Rails.env.profile?
  #   ActiveTriples::Repositories.add_repository :default, RDF::Blazegraph::Repository.new("http://localhost:9999/bigdata/sparql")
  else
    # TODO Production TripleStore TBD -- Need to update once this is properly configured in config/environments/production.rb
    ActiveTriples::Repositories.add_repository :default, RDF::Blazegraph::Repository.new("http://localhost:9999/bigdata/sparql")
    # ActiveTriples::Repositories.add_repository :default, RDF::DataObjects::Repository.new(Rails.configuration.triplestore.default_repository)
  end
end
configure_repositories

Rails.application.config.to_prepare do
  configure_repositories
end
