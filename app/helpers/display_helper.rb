module DisplayHelper

  def render_first_available_partial(partials, options)
    partials.each do |partial|
      begin
        return render(:partial => partial, :locals => options)
      rescue ActionView::MissingTemplate
        next
      end
    end

    raise "No partials found from #{partials.inspect}"


  end

  def field_value_separator
    '<br/>'
  end

  # for display of | delimited fields
  # only displays the string before the first |
  # otherwise, it does same as render_index_field_value
  def render_delimited_index_field_value args
    value = args[:value]

    if args[:field] and blacklight_config.index_fields[args[:field]]
      field_config = blacklight_config.index_fields[args[:field]]
      value ||= send(blacklight_config.index_fields[args[:field]][:helper_method], args) if field_config.helper_method
      value ||= args[:document].highlight_field(args[:field]) if field_config.highlight
    end

    value ||= args[:document].get(args[:field], :sep => nil) if args[:document] and args[:field]

    newval = nil
    unless value.nil?
      if value.class == Array
        newval = Array.new
        value.each do |v|
          newval.push (v.split('|'))[0] unless v.blank?
        end
      else
        ## string?
        newval = (value.split('|'))[0] unless value.blank?
      end
    end

    render_field_value newval
  end

  # for display of | delimited fields
  # only displays the string before the first |
  # otherwise, it does same as render_index_field_value
  def render_pair_delimited_index_field_value args
    value = args[:value]

    if args[:field] and blacklight_config.index_fields[args[:field]]
      field_config = blacklight_config.index_fields[args[:field]]
      value ||= send(blacklight_config.index_fields[args[:field]][:helper_method], args) if field_config.helper_method
      value ||= args[:document].highlight_field(args[:field]) if field_config.highlight
    end

    value ||= args[:document].get(args[:field], :sep => nil) if args[:document] and args[:field]

    newval = nil
    unless value.nil?
      value_array = value.split('|')
      vals = []
      i = 0
      value_array.each do |v|
        vals.push v if i % 2 == 0
        i = i + 1
      end
      newval = vals.join(' / ')
    end

    render_field_value newval
  end

  # :format arg specifies what should be returned
  # * the raw array (url_access_display in availability on item page)
  # * url only (search results)
  # * link_to's with trailing <br>'s -- the default -- (url_other_display &
  # url_toc_display in field listing on item page)
  def render_display_link args
    label = blacklight_config.display_link[args[:field]][:label]
    links = args[:value]
    links ||= args[:document].get(args[:field], :sep => nil) if args[:document] and args[:field]
    render_format = args[:format] ? args[:format] : 'default'

    value = links.map do |link|
      #Check to see whether there is metadata at the end of the link
      url, *metadata = link.split('|')
      if links.size == 1 && render_format == 'url'
        return url.html_safe
      end
      if metadata.present?
        label = metadata[0]
      end
      link_to(process_online_title(label), url.html_safe, {:class => 'online-access'})
    end

    if render_format == 'raw'
      return value
    else
      render_field_value value
    end
  end

  # Build a link to the CUL libraryhours page for the library location in question
  def render_location_link location_code
    base_url = 'http://www.library.cornell.edu/libraryhours'
    matched_location = nil
    # Test for substring match of location hash key in location_code
    LOCATION_MAPPINGS.each do |key, value|
      if location_code.include?(key)
        matched_location = value
        break # Break on first match to ensure RMC (followed by Annex) is properly identified
      end
    end

    location_url = matched_location.present? ? base_url + '?loc=' + matched_location : base_url

    link_to('Hours/Map', location_url, {:title => 'Find this location on a map'})
  end

  # Hash map for substring of location codes from holding service => loc param
  # values for CUL library hours page
  # Built using lists from:
  # -- https://issues.library.cornell.edu/browse/DISCOVERYACCESS-306 (location codes)
  # -- https://issues.library.cornell.edu/browse/DISCOVERYACCESS-408 (site param values)
  LOCATION_MAPPINGS = {
    'rmc' => 'Rare',
    'anx' => 'ANNEX',
    'afr' => 'Africana',
    'engr' => 'ENGR',
    'olin' => 'OLIN',
    'gnva' => 'GENEVA',
    'ilr' => 'ILR',
    'fine' => 'FA',
    'hote' => 'Hotel',
    'asia' => 'Kroch',
    'law' => 'Law',
    'jgsm' => 'JGSM',
    'mann' => 'MANNLIB',
    'math' => 'MATH',
    'phys' => 'PHYSCI',
    'uris' => 'Uris',
    'vet' => 'Vet',
    'orni' => 'Ornithology',
    'mus' => 'Music'
  }

  def render_clickable_document_show_field_value args
    value = args[:value]
    value ||= args[:document].get(args[:field], :sep => nil) if args[:document] and args[:field]
    args[:sep] ||= blacklight_config.multiline_display_fields[args[:field]] || field_value_separator;

    value = [value] unless value.is_a? Array
    value = value.collect { |x| x.respond_to?(:force_encoding) ? x.force_encoding("UTF-8") : x }
    return value.map { |v| render_clickable_item(args, v) }.join(args[:sep]).html_safe
  end

  def render_clickable_item args, value
    clickable_setting = blacklight_config.display_clickable[args[:field]]
    case clickable_setting
    when String
      # default single value
      link_to(value, add_search_params(args[:field], '"' + value + '"'))
    when Hash
      # delimited value to be separated out further
      if clickable_setting[:sep] != nil
        # separator defined
        value_array = value.split(clickable_setting[:sep])
        sep_display = clickable_setting[:sep_display] || clickable_setting[:sep] # separator for display field as defined
        sep_index = clickable_setting[:sep_index] || clickable_setting[:sep] #separator for search string as defined
        if clickable_setting[:key_value]
          # field has display value and search value separated by :sep
          displayv_searchv = value.split(clickable_setting[:sep])
          logger.info clickable_setting.inspect
          if displayv_searchv.size > 2
            # has optional link attributes
            # e.g. uniform title is searched in conjunction with author for more targeted results
            if !clickable_setting[:related_search_field].blank?
              link_to(displayv_searchv[0], add_advanced_search_params(args[:field], displayv_searchv[1], clickable_setting[:related_search_field], displayv_searchv[2]))
            else
              # misconfiguration... no related search field defined
              # ignore related search value
              link_to(displayv_searchv[0], add_search_params(args[:field], '"' + displayv_searchv[1] + '"'))
            end
          elsif displayv_searchv.size > 1
            # default key value pair separated by :sep
            link_to(displayv_searchv[0], add_search_params(args[:field], '"' + displayv_searchv[1] + '"'))
          else
            # display only
            content_tag('span', displayv_searchv[0])
          end
        elsif clickable_setting[:hierarchical]
          # fields such as subject are hierarchical
          hierarchical_value = ''
          value_array.map do |v|
            if !hierarchical_value.empty?
              hierarchical_value += sep_index + v
            else
              hierarchical_value += v
            end
            link_to(v, add_search_params(args[:field], '"' + hierarchical_value + '"'), class: "hierarchical")
          end.join(sep_display).html_safe
        elsif clickable_setting[:pair_list]
          ## fields such as title are hierarchical
          ## e.g. display value 1 | search value 1 | display value 2 | search value 2 ...
          # debugger
          if  value_array.size() > 1
            # i = 0
            # value_array.map do |v|
              # link_to(v, add_search_params(args[:field], '"' + v + '"'))
            # end.join(sep_display).html_safe
            i = 0
            display_list = []
            while i < value_array.size()
              display_list.push link_to(value_array[i], add_search_params(args[:field], '"' + value_array[i+1] + '"'))
              i = i + 2
            end
            display_list.join(sep_display).html_safe
          else
            value_array.map do |v|
              link_to(v, add_search_params(args[:field], '"' + v + '"'))
            end.join(sep_display).html_safe
          end
        else
          # default behavior to search the text displayed
          value_array.map do |v|
            link_to(v, add_search_params(args[:field], '"' + v + '"'))
          end.join(sep_display).html_safe
        end
      else
        # separator not defined... use default behavior
        link_to(value, add_search_params(args[:field], '"' + value + '"'))
      end
    else
      # what other form of input to handle?
    end
  end


  def add_search_params(field, value)
    new_search_params = {
      #:utf8 => '✓',
      :controller => 'catalog',
      :q => value,
      :search_field => get_clickable_search_field(field),
      :click_to_search => true,
      :commit => 'search',
      :action => 'index'
    }
  end

  def add_advanced_search_params(primary_field, pval, related_search_field, rval)
    logger.info "#{primary_field}, #{pval}, #{related_search_field}, #{rval}"
    logger.info get_clickable_search_field(primary_field)
    logger.info get_clickable_search_field(related_search_field)
    op = 'op[]'
    q_row = 'q_row'
    op_row = 'op_row'
    search_field_row = 'search_field_row'
    pf = get_clickable_search_field(primary_field)
    rf = get_clickable_search_field(related_search_field)
    rf = related_search_field if rf.nil?
    boolean_row = 'boolean_row[1]'

    new_search_params = {
      #:utf8 => '✓',
      # :utf8 => '%E2%9C%93',
      q_row.to_sym => [pval, rval],
      op_row.to_sym => ['phrase', 'phrase'],
      search_field_row.to_sym => [pf, rf],
      boolean_row.to_sym => 'AND',
      :sort => 'score desc, pub_date_sort desc, title_sort asc',
      :search_field => 'advanced',
      :commit => 'Search',
      :action => 'index'
    }
  end

  def get_clickable_search_field field
    clickable_setting = get_clickable_setting field
    case clickable_setting
    when String
      # default single value
      return clickable_setting
    when Hash
      # delimited value to be separated out further
      return clickable_setting[:search_field]
    end
  end

  def get_clickable_setting field
    return blacklight_config.display_clickable[field]
  end

  def display_icon?(field)
    return blacklight_config.display_icon[field] != nil
  end

  def display_clickable?(field)
    return get_clickable_setting(field) != nil
  end

  def display_link?(field)
    return blacklight_config.display_link[field] != nil
  end

  def online_url(document)
    if document['url_access_display'].present?
      if document['url_access_display'].size > 1
        catalog_path(document)
      else
        render_display_link(:document => document, :field => 'url_access_display', :format => 'url')
      end
    end
  end

    def finding_aid(document)
    if document['url_findingaid_display'].present?
      if document['url_findingaid_display'].size > 1
        catalog_path(document)
      else
        render_display_link(:document => document, :field => 'url_findingaid_display', :format => 'url')
      end
    end
  end

  FORMAT_MAPPINGS = {
    "Book" => "book",
    "Online" =>"link",
    "Computer File" => 'save',
    "Non-musical Recording" => "headphones",
    "Musical Score" => "musical-score",
    "Musical Recording" => "music",
    "Thesis" => "file-text-o",
    "Microform" => "th",
    "Journal" => "book-open",
    "Conference Proceedings" => "group",
    "Video" => "film",
    "Map or Globe" => "globe",
    "Manuscript/Archive" => "archive",
    "Newspaper" => "newspaper",
    "Database" => "database",
    "Image" => "picture-o",
    "Unknown" => "question-sign",
    "Kit" => "suitcase",
    "Research Guide" => "paste",
    "Course Guide" => "graduation-cap",
    "Website" => "desktop",
    "Miscellaneous" => "ellipsis-h",
    "Object" => "trophy"
  }

  def formats_icon_mapping(format)
    if (icon_mapping = FORMAT_MAPPINGS[format])
      icon_mapping
    else
      'default'
    end
  end

  # Renders the format field values with applicable format icons
  def render_format_value args
    format = args[:document][args[:field]]
    # Convert format to array in case it's a string (it shouldn't be)
    format = [format] unless format.is_a? Array
    format.map do |f|
      icon = '<i class="fa fa-' + formats_icon_mapping(f) + '"></i> '
      f.prepend(icon).html_safe unless f.nil?
    end
  end

  def render_documents(documents, options)
    partial = "/_display/#{options[:action]}/#{options[:view_style]}"
    render partial, { :documents => documents.listify}

  end

  def render_document_view(document, options = {})
    template = options.delete(:template) || raise("Must specify template")
    formats = determine_formats(document, options.delete(:format))

    partial_list = formats.collect { |format| "/_formats/#{format}/#{template}"}
    @add_row_style = options[:style]
    view = render_first_available_partial(partial_list, options.merge(:document => document))
    @add_row_style = nil

    return view
  end

  SOLR_FORMAT_LIST = {
    "Music - Recording" => "music_recording",
    "Music - Score" => "music",
    "Journal/Periodical" => "serial",
    "Journal/Periodical" => "journal",
    "Manuscript/Archive" => "manuscript_archive",
    "Newspaper" => "newspaper",
    "Video" => "video",
    "Map/Globe" => "map_globe",
    "Book" => "book"
  }

  SUMMON_FORMAT_LIST = {
    "Book" => "ebooks",
    "Journal Article" => "article"
  }

# Following line needed for determin_formats method, replace with removed clio array element. See https://issues.library.cornell.edu/browse/DISCOVERYACCESS-310
#  FORMAT_RANKINGS = ["ac", "database", "map_globe", "manuscript_archive", "video", "music_recording", "music", "newspaper", "serial", "book", "clio", "ebooks", "article", "summon", "lweb"]
  FORMAT_RANKINGS = ["ac", "database", "map_globe", "manuscript_archive", "video", "music_recording", "music", "newspaper", "serial", "book", "ebooks", "article", "summon", "lweb"]

  def format_online_results(urls)
    non_circ = image_tag("icons/noncirc.png", :class => :availability)
    urls.collect { |link| non_circ + link_to(process_online_title(link.first).abbreviate(80), link.last) }
  end

  def format_location_results(locations)
    locations.collect do |location|

      loc_display, hold_id = location.split('|DELIM|')

      holdings_id = "holding_" + hold_id.to_s

      image_tag("icons/unknown.png", :class => "availability " + holdings_id) + process_holdings_location(loc_display)
    end
  end

  def determine_formats(document, defaults = [])
    formats = defaults.listify
    formats << "ac" if @active_source == "Academic Commons"
    formats << "database" if @active_source == "Databases"
    case document
    when SolrDocument
# Commenting out following line see https://issues.library.cornell.edu/browse/DISCOVERYACCESS-310
#      formats << "clio"

      document["format"].listify.each do |format|
        formats << SOLR_FORMAT_LIST[format] if SOLR_FORMAT_LIST[format]
      end
    when Summon::Document
      formats << "summon"
      document.content_types.each do |format|
        formats << SUMMON_FORMAT_LIST[format] if SUMMON_FORMAT_LIST[format]
      end
    when SerialSolutions::Link360
      formats << "summon"
    end

    formats.sort { |x,y| FORMAT_RANKINGS.index(x) <=> FORMAT_RANKINGS.index(y) }
  end

  # for segregating search values from display values
  DELIM = "|DELIM|"

  def generate_value_links(values, category)

    # display_value DELIM search_value [DELIM t880_flag]

    out = []

    values.listify.each do |v|
#    values.listify.select { |v| v.respond_to?(:split)}.each do |v|

      s = v.split(DELIM)

      unless s.length >= 2
        out << v
        next
      end

      # if displaying plain text, do not include links

      if @add_row_style == :text
        out << s[0]
      else

        case category
        when :all
          q = '"' + s[1] + '"'
          out << link_to(s[0], url_for(:controller => "catalog", :action => "index", :q => q, :search_field => "all_fields", :commit => "search"))
        when :author
          # s[2] is not nil when data is from an 880 field (vernacular)
          # temp workaround until we can get 880 authors into the author facet
          if s[2]
            # q = '"' + s[1] + '"'
            # out << link_to(s[0], url_for(:controller => "catalog", :action => "index", :q => q, :search_field => "author", :commit => "search"))
            out << s[0]
          else
            # remove puntuation from s[1] to match entries in author_facet using solrmarc removeTrailingPunc rule
            s[1] = s[1].gsub(/\.$/,'') if s[1] =~ /\w{3}\.$/ || s[1] =~ /[\]\)]\.$/
            out << link_to(s[0], url_for(:controller => "catalog", :action => "index", "f[author_facet][]" => s[1]))
          end
        when :subject
          out << link_to(s[0], url_for(:controller => "catalog", :action => "index", :q => s[1], :search_field => "subject", :commit => "search"))
        when :title
          q = '"' + s[1] + '"'
          out << link_to(s[0], url_for(:controller => "catalog", :action => "index", :q => q, :search_field => "title", :commit => "search"))
        else
          raise "invalid category specified for generate_value_links"
        end
      end
    end
    out
  end

  # def generate_value_links_subject(values)
  #
  #   # search value the same as the display value
  #   # quote first term of the search string and remove ' - '
  #
  #   values.listify.collect do |v|
  #
  #     sub = v.split(" - ")
  #     out = '"' + sub.shift + '"'
  #     out += ' ' + sub.join(" ") unless sub.empty?
  #
  #     link_to(v, url_for(:controller => "catalog", :action => "index", :q => out, :search_field => "subject", :commit => "search"))
  #
  #   end
  # end

  def generate_value_links_subject(values)

    # search value the same as the display value
    # but chained to create a series of searches that is increasingly narrower
    # esample: a - b - c
    # link display   search
    #   a             "a"
    #   b             "a b"
    #   c             "a b c"

    values.listify.collect do |value|
#    values.listify.select { |x| x.respond_to?(:split)}.collect do |value|

      searches = []
      subheads = value.split(" - ")
      first = subheads.shift
      display = first
      search = first
      title = first

      searches << build_subject_url(display, search, title)

      unless subheads.empty?
        subheads.each do |subhead|
          display = subhead
          search += ' ' + subhead
          title += ' - ' + subhead
          searches << build_subject_url(display, search, title)
        end
      end

      if @add_row_style == :text
        searches.join(' - ')
      else
        searches.join(' > ')
      end

    end
  end

  def build_subject_url(display, search, title)
    if @add_row_style == :text
      display
    else
      link_to(display, url_for(:controller => "catalog",
                              :action => "index",
                              :q => '"' + search + '"',
                              :search_field => "subject",
                              :commit => "search"),
                              :title => title)
    end
  end

  def add_row(title, value, options = {})
    options.reverse_merge!( {
      :display_blank => false,
      :display_only_first => false,
      :join => nil,
      :abbreviate => nil,
      :html_safe => true,
      :expand => false,
      :style => @add_row_style || :definition
    })

    value_txt = convert_values_to_text(value, options)


    result = ""
    if options[:display_blank] || !value_txt.empty?
      if options[:style] == :text
        result = (title.to_s + ": " + value_txt.to_s + "\r\n").html_safe
      else

        result = content_tag(:div, :class => "row") do
          if options[:style] == :definition
            content_tag(:div, title.to_s.html_safe, :class => "label") + content_tag(:div, content_tag(:div, value_txt, :class => "value_box"), :class => "value")
          elsif options[:style] == :blockquote
            content_tag(:div, content_tag(:div, value_txt, :class => "value_box"), :class => "blockquote")
          end
        end
      end

    end

    result
  end

  def convert_values_to_text(value, options = {})

    values = value.listify

    values = values.collect { |txt| txt.to_s.abbreviate(options[:abbreviate]) } if options[:abbreviate]

    values = values.collect(&:html_safe) if options[:html_safe]
    values = if options[:display_only_first]
      values.first.to_s.listify
    elsif options[:join]
      values.join(options[:join]).to_s.listify.reject { |item| item.to_s.empty? }
    else
      values
    end

    value_txt = if options[:style] == :text
      values.join("\r\n  ")
    else
      pre_values = values.collect { |v| content_tag(:div, v, :class => 'entry') }


      if options[:expand] && values.length > 3
        pre_values = [
          pre_values[0],
          pre_values[1],
          content_tag(:div, link_to("#{values.length - 2} more &#x25BC;".html_safe, "#"), :class => 'entry expander'),
          content_tag(:div, pre_values[2..-1].join('').html_safe, :class => 'expander_more')
        ]

      end

      pre_values.join('')
    end

    value_txt = value_txt.html_safe if options[:html_safe]

    value_txt
  end

  # Test whether we need previous or next document links
  def prev_next_needed(prev_doc, next_doc, prev_bookmark=nil, next_bookmark=nil)
    if (params[:controller] == 'bookmarks' || (prev_bookmark.present? || next_bookmark.present?) || (prev_doc.present? || next_doc.present?))
      return true
    end
  end

  # Test whether we need back to catalog link
  def back_to_catalog_needed
    return !session[:search].blank?
  end

  # The following two methods override originals from blacklight_helper_behavior.rb
  # -- Needed to handle the logic between bookmarks and search results
  def link_to_previous_document(previous_document)
    context = bookmark_or_not(previous_document)
    context_path = context.present? ? context[:url] : previous_document
    context_counter = context.present? ? context[:data_counter] : nil
    link_to_unless previous_document.nil?, raw(t('views.pagination.previous')), context_path, :class => "previous", :rel => 'prev', :'data-counter' => context_counter.present? ? context_counter - 1 : nil do
      content_tag :span, raw(t('views.pagination.previous')), :class => 'previous'
    end
  end

  # Overrides original method from blacklight_helper_behavior.rb
  # -- See comment on previous method for more background info
  def link_to_next_document(next_document)
    context = bookmark_or_not(next_document)
    context_path = context.present? ? context[:url] : next_document
    context_counter = context.present? ? context[:data_counter] : nil
    link_to_unless next_document.nil?, raw(t('views.pagination.next')), context_path, :class => "next", :rel => 'next', :'data-counter' => context_counter.present? ? context_counter + 1 : nil do
      content_tag :span, raw(t('views.pagination.next')), :class => 'next'
    end
  end

  # set URL & counter for previous/next link_to depending on current controller
  def bookmark_or_not(document)
    unless document.blank?
      if params[:controller] == 'bookmarks'
        context = {
          :url => bookmark_path(document)
        }
      else
        context = {
          :url => catalog_path(document),
          :data_counter => session[:search][:counter].to_i
        }
      end
    end
  end

  # Overrides original method from blacklight_helper_behavior.rb
  def link_to_document(doc, opts={:label=>nil, :counter => nil, :results_view => true})
    opts[:label] ||= blacklight_config.index.show_link.to_sym
    label = render_document_index_label doc, opts
    if params[:controller] == 'bookmarks'
      docID = doc.id
      link_to label, '/bookmarks/' + docID
    else
      link_to label, doc, { :'data-counter' => opts[:counter] }.merge(opts.reject { |k,v| [:label, :counter, :results_view].include? k  })
    end
  end

  # link_back_to_catalog()
  # Overrides original method from blacklight_helper_behavior.rb
  # Build the URL to return to the search results, keeping the user's facet, query and paging choices intact by using session.
  def link_back_to_catalog(opts={:label=>nil})
    query_params = session[:search] ? session[:search].dup : {}
    query_params.delete :counter
    query_params.delete :total
    link_url = url_for(query_params)
    logger.info query_params.inspect

    if link_url =~ /bookmarks/ || params[:controller] == 'bookmarks'
      opts[:label] ||= t('blacklight.back_to_bookmarks')
      link_url = bookmarks_path
    end

    opts[:label] ||= t('blacklight.back_to_search')

    link = {}
    link[:url] = link_url
    link[:label] = opts[:label]

    link
  end

  # Next 3 is_x methods used for show_tools view to switch btw catalog & bookmarks
  def is_citable document
    if document.respond_to?(:export_as_mla_citation_txt) || document.respond_to?(:export_as_apa_citation_txt)
      return true
    end
  end

  def is_emailable document
    if document.respond_to?(:to_email_text)
      return true
    end
  end

  def is_exportable document
    if document.export_formats.keys.include?(:refworks_marc_txt) || document.export_formats.keys.include?(:endnote)
      return true
    end
  end

  # Overrides original method from blacklight_helper_behavior.rb
  # -- needed to add .html_safe to avoid html encoding in <title> element
  # Used in the show view for setting the main html document title
  def document_show_html_title document=nil
    document ||= @document
    # Test to ensure that display_title is not missing
    # -- some records in Voyager are missing the title (#DISCOVERYACCESS-552)
    # blacklight_config.show.html_title = "freaky"
    if @document[blacklight_config.show.html_title].present?
      render_field_value(document[blacklight_config.show.html_title].html_safe)
    end
  end

  def borrowdirect_url_from_isbn(isbns)

    # For now, just take the first isbn if there are more than one. BD seems to do fine with any.
    if isbns.length > 0
      isbn = isbns[0]
    else
      isbn = isbns
    end

    # Chop off any dangling text (e.g., 13409872342X (pbk))
    isbn = isbn.scan(/[0-9xX]+/)[0]
    return if isbn.nil?

    link_url = "http://resolver.library.cornell.edu/net/parsebd/?&url_ver=Z39.88-2004&rft_id=urn%3AISBN%3A" + isbn + "&req_id=info:rfa/oclc/institutions/3913"

    link_url

  end

  def borrowdirect_url_from_title(title)

    link_url = "http://resolver.library.cornell.edu/net/parsebd/?&url_ver=Z39.88-2004&rft.btitle=" + title + "&req_id=info:rfa/oclc/institutions/3913"

    link_url

  end

  # Overrides original method from facets_helper_behavior.rb
  # Renders a count value for facet limits with comma delimeter
  def render_facet_count(num)
    content_tag("span", format_num(t('blacklight.search.facets.count', :number => num)), :class => "count")
  end

  # Overrides original method from blacklight_helper_behavior.rb
  # -- Updated to handle arrays (multiple fields specified in config)
  # Used for creating a link to the document show action
  def document_show_link_field document=nil
    blacklight_config.index.show_link.is_a?(Array) ? blacklight_config.index.show_link : blacklight_config.index.show_link.to_sym
  end

  # Overrides original method from blacklight_helper_behavior.rb
  # Renders label for link to document using 'title : subtitle' if subtitle exists
  # Also handle non-Roman script alternatives (vernacular) for title and subtitle
  def render_document_index_label doc, opts
    label = nil
    if opts[:label].is_a?(Array)
      title = doc.get(opts[:label][0], :sep => nil)
      subtitle = doc.get(opts[:label][1], :sep => nil)
      fulltitle_vern = doc.get(opts[:label][2], :sep => nil)

      english = subtitle.present? ? title + ' : ' + subtitle : title

      # If title is missing, fall back to document id (bibid) as last resort
      label ||= english.present? ? english : doc.id

      # If we have a non-Roman script alternative, prepend it
      if fulltitle_vern.present?
        label.prepend(fulltitle_vern + ' / ')
      end
    end
    label ||= doc.get(opts[:label], :sep => nil) if opts[:label].instance_of? Symbol
    label ||= opts[:label].call(doc, opts) if opts[:label].instance_of? Proc
    label ||= opts[:label] if opts[:label].is_a? String
    label ||= doc.id
    render_field_value label
  end

  # Overrides original method from catalog_helper_behavior.rb
  # -- All this just to add commas (via format_num) to total result count
  # Pass in an RSolr::Response. Displays the "showing X through Y of N" message.
  def render_pagination_info(response, options = {})
      pagination_info = paginate_params(response)

   # TODO: i18n the entry_name
      entry_name = options[:entry_name]
      entry_name ||= response.docs.first.class.name.underscore.sub('_', ' ') unless response.docs.empty?
      entry_name ||= t('blacklight.entry_name.default')

      case pagination_info.total_count
        when 0; t('blacklight.search.pagination_info.no_items_found', :entry_name => entry_name.pluralize ).html_safe
        when 1; t('blacklight.search.pagination_info.single_item_found', :entry_name => entry_name).html_safe
        else; t('blacklight.search.pagination_info.pages', :entry_name => entry_name.pluralize, :current_page => pagination_info.current_page, :num_pages => pagination_info.num_pages, :start_num => format_num(pagination_info.start), :end_num => format_num(pagination_info.end), :total_num => format_num(pagination_info.total_count), :count => pagination_info.num_pages).html_safe
      end
  end

  # Overrides original method from catalog_helper_behavior.rb
  # -- Allow for different default sort when browsing
  def current_sort_field
    query_params = session[:search] ? session[:search].dup : {}
    # if no search term is submitted and user hasn't specified a sort
    # assume browsing and use the browsing sort field
    if query_params[:q].blank? and query_params[:sort].blank?
      blacklight_config.sort_fields.values.select { |field| field.browse_default == true }.first
    # otherwise, resume regularly scheduled programming
    else
      blacklight_config.sort_fields[params[:sort]] || (blacklight_config.sort_fields.first ? blacklight_config.sort_fields.first.last : nil )
    end
  end

  # Shadow record sniffer
  def is_shadow_record(document)
    if defined? document.to_marc
      fields = document.to_marc.find_all{|f| ('948') === f.tag }

      fields.each do |field|
        field.each do |sub|
          if h(sub.code) === 'h' and h(sub.value) === 'PUBLIC SERVICES SHADOW RECORD'
            return true
          end
        end
      end

      return false
    end
  end

  # To vernaculate or not...that is the question
  def the_vernaculator(engl, vern)
    display = render_document_show_field_value :document => @document, :field => engl
    vernacular = render_document_show_field_value :document => @document, :field => vern
    display = vernacular +  ' / ' + display unless vernacular.blank?
    return display
  end

  # Display the Solr core for everything but production instance
  def render_solr_core
    unless request.host == 'search.library.cornell.edu' or request.host == 'newcatalog.library.cornell.edu'
      core = Blacklight.solr_config[:url]
      # Remove http protocol string
      start = core.rindex(/http:\/\//) + 7
      display = '<p>Solr core: ' + core[start..-1] + '</p>'
      display.html_safe
    end
  end

  # Clean up isbn in prep for bookcovers via Google Books API
  def bookcover_isbn(document)
    isbn = document['isbn_display']
    unless isbn.blank?
      isbn = isbn.first
      # Find first occurence of a space (remove non integer chars)
      space = isbn.index(' ')
      unless space.blank?
        stop = space - 1
        isbn[0..stop]
      else
        isbn
      end
    end
  end

  # Parse other_id_display field for OCLC numbers
  def bookcover_oclc(document)
    other_ids = document['other_id_display']
    oclc_id = other_ids.find { |e| /^\(OCoLC\)/ =~ e } unless other_ids.blank?
    unless oclc_id.blank?
      # Remove '(OCLC)' prefix
      # -- really need to ask Frances about making OCLC# its own field
      oclc_id.gsub(/^\(OCoLC\)/, '')
    end
  end

  # Overrides original method from facets_helper_behavior.rb
  # -- Replace icon-remove (glyphicon) with appropriate Font Awesome classes
  # Standard display of a SELECTED facet value, no link, special span
  # with class, and 'remove' button.
  def render_selected_facet_value(facet_solr_field, item)
    #Updated class for Bootstrap Blacklight 
    content_tag(:span, render_facet_value(facet_solr_field, item, :suppress_link => true), :class => "selected") +
      link_to(content_tag(:i, '', :class => "fa fa-times") + content_tag(:span, '[remove]', :class => 'hide-text'), remove_facet_params(facet_solr_field, item, params), :class=>"remove")
  end

end
