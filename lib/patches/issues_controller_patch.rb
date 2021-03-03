require_dependency 'issues_controller'

module Patches

  module IssuesControllerPatch

    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method :create_without_sharepoint, :create
        alias_method :create, :create_with_sharepoint

        alias_method :build_new_issue_from_params_without_extend, :build_new_issue_from_params
        alias_method :build_new_issue_from_params, :build_new_issue_from_params_with_extend
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
          custom_field_config['issue_custom_field_2_id'] => 'file:///' + sharepoint_config['site_url'] + '@SSL/DavWWWRoot/Shared Documents/□②事務/◎①見積・発注/' + folder_name ,
          custom_field_config['issue_custom_field_3_id'] => 'ms-excel:ofe|u|https://' + sharepoint_config['site_url'] + '/Shared Documents/□②事務/◎①見積・発注/' + folder_name + '/' + file_name,
          custom_field_config['issue_custom_field_4_id'] => '0' * pad_length + @issue.id.to_s
        }

        @issue.save
      end

      def build_new_issue_from_params_with_extend
        @issue = Issue.new
        if params[:copy_from]
          begin
            @issue.init_journal(User.current)
            @copy_from = Issue.visible.find(params[:copy_from])
            unless User.current.allowed_to?(:copy_issues, @copy_from.project)
              raise ::Unauthorized
            end
            if params[:role] == 'estimate'
              @link_copy = link_copy?(params[:link_copy]) || request.get?
              @copy_attachments = params[:copy_attachments].present? || request.get?
              @copy_subtasks = params[:copy_subtasks].present? || request.get?
              @copy_watchers = User.current.allowed_to?(:add_issue_watchers, @project)
              @issue.copy_from(@copy_from, :attachments => @copy_attachments, :subtasks => @copy_subtasks, :watchers => @copy_watchers, :link => @link_copy)
              @issue.parent_issue_id = @copy_from.parent_id
            end
          rescue ActiveRecord::RecordNotFound
            render_404
            return
          end
        end
        @issue.project = @project
        if request.get?
          @issue.project ||= @issue.allowed_target_projects.first
        end
        @issue.author ||= User.current
        @issue.start_date ||= User.current.today if Setting.default_issue_start_date_to_creation_date?

        attrs = (params[:issue] || {}).deep_dup
        if action_name == 'new' && params[:was_default_status] == attrs[:status_id]
          attrs.delete(:status_id)
        end
        if action_name == 'new' && params[:form_update_triggered_by] == 'issue_project_id'
          # Discard submitted version when changing the project on the issue form
          # so we can use the default version for the new project
          attrs.delete(:fixed_version_id)
        end
        attrs[:assigned_to_id] = User.current.id if attrs[:assigned_to_id] == 'me'
        @issue.safe_attributes = attrs

        if @issue.project
          @issue.tracker ||= @issue.allowed_target_trackers.first
          if @issue.tracker.nil?
            if @issue.project.trackers.any?
              # None of the project trackers is allowed to the user
              render_error :message => l(:error_no_tracker_allowed_for_new_issue_in_project), :status => 403
            else
              # Project has no trackers
              render_error l(:error_no_tracker_in_project)
            end
            return false
          end
          if @issue.status.nil?
            render_error l(:error_no_default_issue_status)
            return false
          end
        elsif request.get?
          render_error :message => l(:error_no_projects_with_tracker_allowed_for_new_issue), :status => 403
          return false
        end

        @priorities = IssuePriority.active
        @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
      end

    end

  end

end

IssuesController.send(:include, Patches::IssuesControllerPatch)
