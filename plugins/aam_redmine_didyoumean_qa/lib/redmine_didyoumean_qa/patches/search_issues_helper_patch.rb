module RedmineDidyoumeanQa
  module Patches
    module SearchIssuesHelperPatch
      def issues_didyoumean_qa_event_type
        if Setting.plugin_aam_redmine_didyoumean_qa['start_search_when'] == "1"
          "keyup"
        else
          "change"
        end
      end
    end
  end
end
