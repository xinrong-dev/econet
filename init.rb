Redmine::Plugin.register :econet do
  name 'Econet plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end

require 'hooks/view_layouts_base_html_head_hook'
require 'hooks/view_layouts_base_body_bottom_hook'
