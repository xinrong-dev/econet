module Hooks
  class ViewLayoutsBaseHtmlHeadHook < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context={})
      tags = stylesheet_link_tag("econet", :plugin => "econet", :media => "screen")
    end
  end
end
