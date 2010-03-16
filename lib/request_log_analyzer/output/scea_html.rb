module RequestLogAnalyzer::Output

  # HTML Output class. Generated a HTML-formatted report, including CSS.
  class SceaHTML < Base

    # def initialize(io, options = {})
    #   super(io, options)
    # end

    def colorize(text, *style)
      if style.include?(:bold)
        tag(:strong, text)
      else
        text
      end
    end

    # Print a string to the io object.
    def print(str)
      @io << str
    end

    alias :<< :print

    # Put a string with newline
    def puts(str = '')
      @io << str << "<br/>\n"
    end

    # Place a title
    def title(title)
      @io.puts(tag(:h2, title))
    end

    # Render a single line
    # <tt>*font</tt> The font.
    def line(*font)
      @io.puts(tag(:hr))
    end

    # Write a link
    # <tt>text</tt> The text in the link
    # <tt>url</tt> The url to link to.
    def link(text, url = nil)
      url = text if url.nil?
      tag(:a, text, :href => url)
    end
    
    def report_tracker(tracker)
      @io << "<div class='tabbertab' title='#{tracker.title}'>"
      tracker.report(self)
      @io << '</div>'
    end

    # Generate a report table in HTML and push it into the output object.
    # <tt>*colums<tt> Columns hash
    # <tt>&block</tt>: A block yeilding the rows.
    def table(columns, table_opts={}, &block)
      rows = Array.new
      yield(rows)

      @io << tag(:table, {:cellspacing => 0, :class => 'report-table'}.merge(table_opts)) do |content|
        if table_has_header?(columns)
          content << tag(:tr) do
            columns.map{|col| tag(:th, col[:title], extracted_html_options(col)) }.join("\n")
          end
        end

        odd = false
        rows.each do |row|
          odd = !odd
          content << tag(:tr) do
            if odd
              row.map { |cell| tag(:td, cell, :class => 'alt') }.join("\n")
            else
              row.map { |cell| tag(:td, cell) }.join("\n")
            end
          end
        end
      end

    end

    # Genrate HTML header and associated stylesheet
    def header
      @io.content_type = content_type if @io.respond_to?(:content_type)

      @io << "<html>"
      @io << tag(:head) do |headers|
        # tabber_js_file    = File.expand_path(File.join(File.dirname(__FILE__), 'scea', 'tabber-minimized.js'))
        table_sorter_file = File.expand_path(File.join(File.dirname(__FILE__), 'scea', 'table-sorter.js'))
        css_file          = File.expand_path(File.join(File.dirname(__FILE__), 'scea', 'style.css'))

        headers << tag(:title, 'SCEA Log Analyzer Report')
        headers << tag(:style, File.open(css_file).read, :type => "text/css")
        # headers << tag(:script, File.open(tabber_js_file).read, :type => 'text/javascript')
        headers << tag(:script, File.open(table_sorter_file).read, :type => 'text/javascript')
      end
      @io << '<body>'
      @io << tag(:h1, 'SCEA Log Analyzer Report')
      # @io << tag(:p, "Version #{RequestLogAnalyzer::VERSION}")
    end
    
    # wrap the report body in this method
    def wrapper
      @io << "<div class='tabber'>"
      yield(self)
      @io << "</div>"
    end

    # Generate a footer for a report
    def footer
      # @io << tag(:hr) << tag(:h2, 'Thanks for using request-log-analyzer')
      # @io << tag(:p, 'For more information please visit the ' + link('Request-log-analyzer website', 'http://github.com/wvanbergen/request-log-analyzer'))
      @io << "</body></html>\n"
    end

    protected

    def extracted_html_options(opts)
      output = ""
      output << " id='#{opts[:id]}" if opts[:id]
      output << " class='#{opts[:class]}'" if opts[:class]
      output
    end

    # HTML tag writer helper
    # <tt>tag</tt> The tag to generate
    # <tt>content</tt> The content inside the tag
    # <tt>attributes</tt> Attributes to write in the tag
    def tag(tag, content = nil, attributes = nil)
      if block_given?
        attributes = content.nil? ? '' : ' ' + content.map { |(key, value)| "#{key}=\"#{value}\"" }.join(' ')
        content_string = ''
        content = yield(content_string)
        content = content_string unless content_string.empty?
        "<#{tag}#{attributes}>#{content}</#{tag}>"
      else
        tattributes = if attributes.nil?
          ''
        elsif attributes.respond_to?(:map)
          ' ' + attributes.map { |(key, value)| "#{key}=\"#{value}\"" }.join(' ')
        else
          ' ' + attributes
        end
        if content.nil?
          "<#{tag}#{tattributes} />"
        else
          if content.class == Float
            "<#{tag}#{tattributes}><div class='color_bar' style=\"width:#{(content*200).floor}px;\"/></#{tag}>"
          else
            "<#{tag}#{tattributes}>#{content}</#{tag}>"
          end
        end
      end
    end
  end
end