# -*- encoding : utf-8 -*-
class DatabasesController < ApplicationController
  include Blacklight::Catalog
  include BlacklightCornell::CornellCatalog
  #include BlacklightUnapi::ControllerExtension
  before_filter :heading

  def heading
   @heading='Databases'
  end


  def subject
     clnt = HTTPClient.new
    #params[:q].gsub!(' ','%20')
#     @anthroString = clnt.get_content("http://da-dev-solr.library.cornell.edu/solr/blacklight/select?q=%22anthropology+%28core%29%22&wt=ruby&indent=true") # do |chunk|
     Rails.logger.debug("es287_debug #{__FILE__} #{__LINE__}  = #{Blacklight.solr_config.inspect}")
     solr = Blacklight.solr_config[:url]
     p = {"q" => '"' + params[:q] +'"', "wt" => 'json',"indent"=>"true"}
     Rails.logger.debug("es287_debug #{__FILE__} #{__LINE__}  = " + "#{solr}/databasesBySubject?"+p.to_param)
     @subjectString = clnt.get_content("#{solr}/databasesBySubject?wt=json&"+p.to_param)
     @subjectResponse = JSON.parse(@subjectString)
       @subject = @subjectResponse['response']['docs']

    p = {"q" => '"' + params[:q] +' (Core)"', "wt" => 'json',"indent"=>"true"}
    Rails.logger.debug("es287_debug #{__FILE__} #{__LINE__}  = " + "#{solr}/databasesBySubject?"+p.to_param)
    @subjectCoreString = clnt.get_content("#{solr}/databasesBySubject?" + p.to_param)
     @subjectCoreResponse = JSON.parse(@subjectCoreString)
    @subjectCore = @subjectCoreResponse['response']['docs']
     params[:q].gsub!('%20', ' ')
    end

  def title
        clnt = HTTPClient.new
        Rails.logger.info("es287_debug #{__FILE__} #{__LINE__}  = #{Blacklight.solr_config.inspect}")
        solr = Blacklight.solr_config[:url]
        p = {"q" => '"' + params[:alpha] +'"', "wt" => 'json',"indent"=>"true"}
        @aString = clnt.get_content("#{solr}/databaseAlphaBuckets?" + p.to_param)
        @aResponse = JSON.parse(@aString)
     #   @aResponse = eval(@aString)
        @a = @aResponse['response']['docs']
    end


      def show
        clnt = HTTPClient.new
        Rails.logger.info("es287_debug #{__FILE__} #{__LINE__}  = #{Blacklight.solr_config.inspect}")
        solr = Blacklight.solr_config[:url]
        p = {"id" => params[:id], "wt" => 'json',"indent"=>"true"}
        @dbString = clnt.get_content("#{solr}/database?"+p.to_param)
        @dbResponse = JSON.parse(@dbString)
        #@dbResponse = eval(@dbString)
        @db = @dbResponse['response']['docs']
    end



   def searchdb
      if params[:q].nil? or params[:q] == ""
        flash.now[:error] = "Please enter a query."
        render "index"
      end
      if !params[:q].nil? and params[:q] != ""
        #params[:q].gsub!(' ','%20')
        dbclnt = HTTPClient.new
        Rails.logger.info("es287_debug #{__FILE__} #{__LINE__}  = #{Blacklight.solr_config.inspect}")
        solr = Blacklight.solr_config[:url]
        p = {"q" =>params[:q] , "wt" => 'json',"indent"=>"true","defType" =>"dismax"}
        Rails.logger.info("es287_debug #{__FILE__} #{__LINE__}  = " + "#{solr}/databases?"+p.to_param)
        @dbResultString = dbclnt.get_content("#{solr}/databases?" + p.to_param)
        if !@dbResultString.nil?
           @dbResponseFull = JSON.parse(@dbResultString)
        else
           @dbResponseFull = eval("Could not find")
        end
        @dbResponse = @dbResponseFull['response']['docs']
        params[:q].gsub!('%20', ' ')
      end
    end


# DO NOT USE this method.  It has been replaced by tou below.  This method relied on passed parameters which supposedly could lead to an SQL injection attack.
# JAC244 8/13/2015
  if false
  def searchERMdb

    clnt = HTTPClient.new
    Rails.logger.info("es287_debug #{__FILE__} #{__LINE__}  = #{Blacklight.solr_config.inspect}")
    solr = Blacklight.solr_config[:url]
    @dbString = clnt.get_content("#{solr}/database?id=#{params[:id]}")
    @dbResponse = eval(@dbString)
    @db = @dbResponse['response']['docs']

     @defaultRightsText = ''
     if params[:dbcode].nil? or params[:dbcode] == '' #check for providerCode being nil
#       if params[:providercode].nil? or params[:providercode] == '' #use default rights text
#         @defaultRightsText = "Use default rights text"
#       else
#         @ermDBResult = Erm_data.where(Provider_Code: params[:providercode], Prevailing: 'true')
#         if @ermDBResult.size < 1
           @defaultRightsText = "Use default rights text"
#         end
#       end
     else
       @ermDBResult = ::Erm_data.where(Database_Code: params[:dbcode], Prevailing: 'true')
       if @ermDBResult.size < 1
         @ermDBResult = ::Erm_data.where("Provider_Code = '#{params[:providercode]}' AND Prevailing = 'true' AND (Database_Code =  '' OR Database_Code IS NULL)")
         if @ermDBResult.size < 1
           @defaultRightsText = "DatabaseCode and ProviderCode returns nothing"
         end
       end
     end

   @column_names = ::Erm_data.column_names.collect(&:to_sym)

  end
  end

# Replacement for searchERMdb.  See comment above searchERMdb method.
  def tou

    clnt = HTTPClient.new
    Rails.logger.info("es287_debug #{__FILE__} #{__LINE__}  = #{Blacklight.solr_config.inspect}")
    solr = Blacklight.solr_config[:url]
    p = {"id" =>params[:id] , "wt" => 'json',"indent"=>"true"}
    @dbString = clnt.get_content("#{solr}/database?"+p.to_param)
    @dbResponse = JSON.parse(@dbString)
    @db = @dbResponse['response']['docs']
    dbcode = @dbResponse['response']['docs'][0]['dbcode']
    providercode = @dbResponse['response']['docs'][0]['providercode']
     @defaultRightsText = ''
     if dbcode.nil? or dbcode == '' #check for providerCode being nil
           @defaultRightsText = "Use default rights text"
     else
       @ermDBResult = ::Erm_data.where(Database_Code: "\'#{dbcode[0]}\'", Prevailing: 'true')
       if @ermDBResult.size < 1
         @ermDBResult = ::Erm_data.where("Provider_Code = \'#{providercode[0]}\' AND Prevailing = 'true' AND (Database_Code =  '' OR Database_Code IS NULL)")

         if @ermDBResult.size < 1
           @defaultRightsText = "DatabaseCode and ProviderCode returns nothing"
         end
       end
     end

   @column_names = ::Erm_data.column_names.collect(&:to_sym)

  end

end
