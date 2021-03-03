module Hooks
  class ViewLayoutsBaseHtmlHeadHook < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context={})
      custom_field_config = YAML.load_file(File.join(__dir__, '../../config/custom_field.yml'))
      tags = [stylesheet_link_tag("econet", :plugin => "econet", :media => "screen")]
      tags << javascript_tag(
        'var projectSharepointFieldID = "' + custom_field_config['project_custom_field_1_id'] +
        '"; var issueCustomerFieldID = "' + custom_field_config['issue_custom_field_1_id'] +
        '"; var issueSharepointFolderFieldID = "' + custom_field_config['issue_custom_field_2_id'] +
        '"; var issueSharepointFileFieldID = "' + custom_field_config['issue_custom_field_3_id'] + '"'
      )
      return tags.join(' ')
    end
  end
end
