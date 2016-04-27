require 'httparty'
require 'pry'
class MetadataCallback

  include HTTParty
  default_timeout 1 # hard timeout after 1 second


  class << self

    ###  This allows me to get the url and path of BookMetadataController#metadata

    # include Rails.application.routes
    include Rails.application.routes.url_helpers
    def default_url_options
      ActionMailer::Base.default_url_options
    end
  end

  def self.attempt_generic_metadata_extraction( uris )
    # host is not registered - attempting extraction anyway
    items_metadata = []
    uris.each do |uri|
      item_metadata = LD4L::WorksRDF::AttemptGenericMetadataExtraction.call(uri)
      parsable_uri = URI.parse(uri)
      item_metadata.source = parsable_uri.host
      items_metadata << item_metadata
    end
    items_metadata
  end

  def self.get_localhost_metadata_from_marcxml( uris )
    # ex. URI - http://localhost/catalog/5449293

    items_metadata = []
    uris.each do |uri|
      parsable_uri = URI.parse(uri)
      uri = "http://newcatalog.library.cornell.edu#{parsable_uri.path}"
      item_metadata = LD4L::WorksRDF::GetMetadataFromMarcxmlURI.call(uri)
      item_metadata.source = 'Cornell Catalog'
      items_metadata << item_metadata
    end
    items_metadata
  end

  def self.get_cornell_metadata_from_marcxml( uris )
    # ex. URI - http://newcatalog.library.cornell.edu/catalog/5449293

    items_metadata = []
    uris.each do |uri|
      item_metadata = LD4L::WorksRDF::GetMetadataFromMarcxmlURI.call(uri)
      item_metadata.source = 'Cornell Catalog'
      items_metadata << item_metadata
    end
    items_metadata
  end

  def self.get_cornell_metadata_from_solr( uris )
    # ex. URI - http://newcatalog.library.cornell.edu/catalog/5449293

    solr_query = "http://da-stg-ssolr.library.cornell.edu/solr/blacklight/select?facet=false&fq=id:("

    or_str = ""
    uris.each do |uri|
      local_id = URI.parse(uri).path.split('/').last
      solr_query += or_str + local_id
      or_str = " OR "
    end
    solr_query += ")"
    LD4L::WorksRDF::GetMetadataFromSolrQuery.call(solr_query, nil)
  end

  def self.get_stanford_metadata_from_marcxml( uris )
    # ex. URI - http://searchworks.stanford.edu/view/2285631

    items_metadata = []
    uris.each do |uri|
      item_metadata = LD4L::WorksRDF::GetMetadataFromMarcxmlURI.call(uri,"a")
      item_metadata.source = 'Stanford Catalog'
      items_metadata << item_metadata
    end
    items_metadata
  end

  def self.get_harvard_metadata_from_XXX( uris )
    # ex. Permalink - http://id.lib.harvard.edu/aleph/004915193/catalog

    items_metadata = []
    uris.each do |uri|
      item_metadata = LD4L::WorksRDF::WorkMetadata.new(nil)
      item_metadata.uri    = uri
      item_metadata.source = 'Harvard Catalog'
      item_metadata.title  = 'TEST TITLE'
      item_metadata.author = 'TEST AUTHOR'
      item_metadata.set_type_to_book
      items_metadata << item_metadata
    end
    items_metadata
  end

  def self.get_cornell_vivo_metadata( uris )
    # ex. URI - http://vivo.cornell.edu/individual/n56611
    items_metadata = []
    uris.each do |uri|
      item_metadata = LD4L::WorksRDF::GetMetadataFromVivoURI.call(uri)
      item_metadata.source = 'Cornell VIVO'
      items_metadata << item_metadata
    end
    items_metadata
  end

  def self.get_oclc_metadata( uris )
    # ex. Permalink - http://www.worldcat.org/oclc/785874920
    items_metadata = []
    uris.each do |uri|
      item_metadata = LD4L::WorksRDF::GetMetadataFromOclcURI.call(uri)
      item_metadata.source = 'OCLC Worldcat'
      items_metadata << item_metadata
    end
    items_metadata
  end
end