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
        config = YAML.load_file(File.join(__dir__, '../../config/sharepoint.yml'))
        create_without_sharepoint

        id_length = @issue.id.to_s.length
        pad_length = 8 - id_length
        ticket_id = '0' * pad_length + @issue.id.to_s
        folder_name = @issue.project.name + '/' + ticket_id + '.' + @issue.subject

        sharepoint_create_folder(sharepoint_access_token, folder_name)
        sharepoint_upload_file(sharepoint_access_token, ticket_id + '.' + @issue.subject, '見積書フォーマット.xlsx')

        @issue.custom_field_values = {
          '33' => 'https://' + config['site_url'] + '/Shared Documents/□②事務/◎①見積・発注/' + folder_name ,
          '34' => 'ms-excel:ofe|u|https://' + config['site_url'] + '/Shared Documents/□②事務/◎①見積・発注/' + folder_name + '/見積書フォーマット.xlsx',
          '35' => '0' * pad_length + @issue.id.to_s
        }

        @issue.save
      end

    end

  end

end

IssuesController.send(:include, Patches::IssuesControllerPatch)
