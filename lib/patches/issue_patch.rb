# frozen_string_literal: true

require_dependency 'issue'

module Patches

  module IssuePatch

    def self.included(base)
      base.class_eval do
        unloadable
        validates_presence_of :start_date, :due_date
      end
    end

  end

end

Issue.include Patches::IssuePatch
