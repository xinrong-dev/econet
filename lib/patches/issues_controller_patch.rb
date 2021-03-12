require_dependency 'issues_controller'

module Patches

  module IssuesControllerPatch

    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method :create_without_sharepoint, :create
        alias_method :create, :create_with_sharepoint
      end
    end

    module InstanceMethods

      include Sharepoint::SharepointRestfulApi

      def create_with_sharepoint
        custom_field_config = YAML.load_file(File.join(__dir__, '../../config/custom_field.yml'))
        sharepoint_config = YAML.load_file(File.join(__dir__, '../../config/sharepoint.yml'))
        create_without_sharepoint

        id_length = @issue.id.to_s.length
        pad_length = 8 - id_length
        ticket_id = '0' * pad_length + @issue.id.to_s

        if ticket_id != '00000000'
          folder_name = '01.見積/' + params[:issue][:custom_field_values][custom_field_config['issue_custom_field_5_id']]
       
          sharepoint_create_folder(sharepoint_access_token, folder_name)
  
          if params[:issue][:custom_field_values][custom_field_config['issue_custom_field_6_id']] != ''
            folder_name = folder_name + '/' + params[:issue][:custom_field_values][custom_field_config['issue_custom_field_6_id']]
            sharepoint_create_folder(sharepoint_access_token, folder_name)
          end
          if params[:issue][:custom_field_values][custom_field_config['issue_custom_field_7_id']] != ''
            folder_name = folder_name + '/' + params[:issue][:custom_field_values][custom_field_config['issue_custom_field_7_id']]
            sharepoint_create_folder(sharepoint_access_token, folder_name)
          end
  
          folder_name = folder_name + '/' + ticket_id + '【' + params[:issue][:custom_field_values][custom_field_config['issue_custom_field_8_id']] + '】' +
            params[:issue][:custom_field_values][custom_field_config['issue_custom_field_1_id']]
          file_name = '【' + params[:issue][:custom_field_values][custom_field_config['issue_custom_field_8_id']] + '】' +
            params[:issue][:custom_field_values][custom_field_config['issue_custom_field_1_id']] + '　計算表.xlsx'
          
          sharepoint_create_folder(sharepoint_access_token, folder_name)
          sharepoint_upload_file(sharepoint_access_token, folder_name, file_name)
  
          @issue.custom_field_values = {
            custom_field_config['issue_custom_field_2_id'] => 'file:///\\\\' + sharepoint_config['site_url'] + '@SSL/DavWWWRoot/Shared Documents/□②事務/◎①見積・発注/' + folder_name ,
            custom_field_config['issue_custom_field_3_id'] => 'ms-excel:ofe|u|https://' + sharepoint_config['site_url'] + '/Shared Documents/□②事務/◎①見積・発注/' + folder_name + '/' + file_name,
            custom_field_config['issue_custom_field_4_id'] => '0' * pad_length + @issue.id.to_s
          }
  
          @issue.save
        end
        
      end

    end

  end

end

IssuesController.send(:include, Patches::IssuesControllerPatch)
