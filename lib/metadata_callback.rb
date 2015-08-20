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
binding.pry
    # ex. Permalink - http://www.worldcat.org/oclc/785874920
    items_metadata = []
    uris.each do |uri|
      item_metadata = LD4L::WorksRDF::GetMetadataFromOclcURI.call(uri)
      item_metadata.source = 'OCLC Worldcat'
      items_metadata << item_metadata
    end
    items_metadata
  end

#   def self.get_cornell_metadata_from_solr( items_metadata )
#
#     uris = items_metadata.keys
#     uri = uris.first
#     ids = uris.collect { |uri| URI(uri).path.split('/').last }
#     id = ids.first
#
#
#     # x = Rails.application.routes.url_helpers.send("metadata/#{ids.first}.json")
#     url = MetadataCallback.metadata_url(:id => id, :host => "#{URI(uri).host}:#{URI(uri).port}")
#     jurl = MetadataCallback.metadata_url(:id => id, :host => "#{URI(uri).host}:#{URI(uri).port}")+".json"
#     path = MetadataCallback.metadata_path(:id => id)
#
#     puts( "*** Entering MetadataCallback.fill_in_metadata -- id = #{id}   url = #{url}")
#
#     ###  Trying to use Dispatch to call BookMetadata#metadata
#     ###     - Don't know where env is supposed to come from so tried without including env
#
#     # x = MyVirtualCollectionsController.action(:metadata).call
#     # x = MyVirtualCollectionsController.action(:metadata).call(env)
#
#     # binding.pry
#
#     ###  Trying to use Dispatch with a more direct call to Dispatch
#
#     # url = ActionDispatch::Routing::UriFor.url_for(controller: 'my_virtual_collections',
#     #               action:     'metadata',
#     #               trailing_slash: true ) + "#{id}.json"
#
#     # binding.pry
#
#
#     ###  Trying HTTParty gem which ultimately uses Net::HTTP
#
#     puts("------ calling HTTParty.get(#{jurl})")
#     # response = HTTParty.get(jurl, { :timeout => 2 })    # call when not including HTTParty
#     response = self.get(jurl,{ :timeout => 5 })     # call with self when include HTTParty at top of class
#     puts( "------ response from HTTParty = #{response}")
# # binding.pry
#
#
# ###  Trying Net::HTTP calls
# ###     - times out
#
# # url = URI.parse(url)
# # req = Net::HTTP::Get.new(url.to_s)
# # req.add_field('Accept','application/json')
# # res = Net::HTTP.start(url.host, url.port) {|http|
# #   http.request(req)
# # }
# # puts res.body
#
#
# ###  Trying a single line call to Net::HTTP
# ###     - times out
#
# # res = Net::HTTP.get(path, { 'Accept' => 'application/json' } )
#
# # binding.pry
#
#
# ###  Trying Curl
# ###     - times out
#
# # puts ( "------ call Curl.get(#{url})" )
# # http = Curl.get(url) do |curl|
# #   curl.headers['Accept'] = 'application/json'
# #   curl.headers['Content-Type'] = 'application/json'
# #   curl.headers['Api-Version'] = '2.2'
# #   curl.follow_location = true
# #   curl.max_redirects = 1
# #   curl.connect_timeout = 1
# #   curl.useragent = "curb"
# #   curl.on_redirect do |easy|
# #     # puts http.header_str
# #     # easy.headers['Accept'] = 'text/ttl'
# #     # easy.headers['Content-Type'] = 'text/ttl'
# #     # easy.headers['Api-Version'] = '2.2'
# #     puts "set header again for redirect"
# #   end
# # end
# # result = http.body_str
# # header = http.header_str
# # puts( "------ header = #{header}")
#
# # binding.pry
#
#
# ###  Trying call to get
# ###     - get method doesn't exist in controller
#
# # get "metadata/#{ids.first}", {}, { "Accept" => "application/json" }
#
# # binding.pry
#
#
# #     # TODO:  LEFT OFF HERE TRYING TO GET get_solr_response_for_field_values to work
# #     # complaining about params not being set
# #
# #     params = {}
# #     params[:view] = "index"
# #     params[:controller] = "bookmarks"
# #     params[:ids] = ids
# #
# #     params = ActionController::Parameters.new_from_hash_copying_default(params)
# # binding.pry
# #
# #     # x = Holding.fetch(ids.first)
# #     # @holdings = JSON.parse(HTTPClient.get_content("http://es287-dev.library.cornell.edu:8950/holdings/fetch/#{params[:id]}"))[params[:id]]
# #     @holdings = JSON.parse(HTTPClient.get_content("http://es287-dev.library.cornell.edu:8950/holdings/fetch/#{ids.first}"))[ids.first]
# #
# #     # @response, @document = BookmarksController.new.get_solr_response_for_doc_id
# #
# #     # @response, @document_list = BookmarksController.new.index_given_ids(params)
# #     # @response, @document_list = CatalogController.new.citation(ids.first)
# #
# #
# #
# #
# # binding.pry
# #     puts "here"
# #     #
# #     # items_metadata.each do |id, item|
# #     #   item
# #     # end
#   end

end