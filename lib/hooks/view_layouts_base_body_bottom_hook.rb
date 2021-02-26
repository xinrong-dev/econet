module Hooks
  class ViewLayoutsBaseBodyBottomHook < Redmine::Hook::ViewListener
    def view_layouts_base_body_bottom(context={})
      tags = javascript_include_tag("econet", :plugin => "econet")
    end
  end
end
