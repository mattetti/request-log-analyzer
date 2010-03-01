module RequestLogAnalyzer::FileFormat

  # The Apache file format is able to log Apache access.log files.
  #
  # The access.log can be configured in Apache to have many different formats. In theory, this
  # FileFormat can handle any format, but it must be aware of the log formatting that is used
  # by sending the formatting string as parameter to the create method, e.g.:
  #
  #     RequestLogAnalyzer::FileFormat::Apache.create('%h %l %u %t "%r" %>s %b')
  #
  # It also supports the predefined Apache log formats "common" and "combined". The line
  # definition and the report definition will be constructed using this file format string.
  # From the command line, you can provide the format string using the <tt>--apache-format</tt>
  # command line option.
  # require File.expand_path(File.join(File.dirname(__FILE__),'apache'))
  
  # Nginx scea
  class SceaNginx < Apache
    LOG_DIRECTIVES['i'] = { 
                'Platform'   => { :regexp => '(.*)', :captures => [{:name => :platform, :type => :nillable_string}] },
             }

    
    def self.access_line_definition(format_string)
      scea_nginx_format_string = '%h - - %t %s "%r" %b "-" "%{Referer}i (%{Platform}i) %{User-agent}i" "-" (%T)'
      super('%h - - %t %s "%r" %b "-" "%{Referer}i (%{Platform}i) %{User-agent}i" "-" (%T)')
    end
    
  end
end