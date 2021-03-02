require_dependency 'projects_controller'

module Patches

  module ProjectsControllerPatch

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

        if params[:project][:custom_field_values]['31'] == ''
          params[:project][:custom_field_values]['31'] = 'file:///' + config['site_url'] + '@SSL/DavWWWRoot/Shared Documents/□②事務/◎①見積・発注/' + params[:project]['name']
        end
        if params[:project][:custom_field_values]['32'] == ''
          params[:project][:custom_field_values]['32'] = params[:project]['name']
        end
        create_without_sharepoint

        sharepoint_create_folder(sharepoint_access_token, params[:project]['name'])
      end

    end

  end

end

ProjectsController.send(:include, Patches::ProjectsControllerPatch)
