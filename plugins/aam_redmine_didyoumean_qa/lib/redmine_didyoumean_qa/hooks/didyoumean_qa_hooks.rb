module DidYouMeanQa
  class DidYouMeanQaHooks < Redmine::Hook::ViewListener
  	render_on(:view_issues_form_details_bottom, :partial => 'didyoumean_qa_injected', :handlers => [:erb], :formats => [:html])
  end
end
