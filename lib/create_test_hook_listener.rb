class CreateTestHookListener < Redmine::Hook::ViewListener

  render_on :view_issues_show_description_bottom, :partial => "create_test/link"
end
