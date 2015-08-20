class MyVirtualCollectionsController < CatalogController

  ##
  # Give Bookmarks access to the CatalogController configuration
  include Blacklight::Configurable
  include Blacklight::SolrHelper

  copy_blacklight_config_from(CatalogController)

  def metadata
    ids = []
    ids << params[:id]
    @response, @document_list = get_solr_response_for_field_values(SolrDocument.unique_key, ids)
    respond_to do |format|
      format.json
    end
  end

end