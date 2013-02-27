# require 'redmine'

require_dependency "create_test_hook_listener"

Redmine::Plugin.register :create_test do
  name 'Create Test plugin'
  author 'Pavel Pokorny'
  description 'Create a test issue'
  version '0.0.1'
  project_module :create_test do
    permission :create_test_from_issue, :create_test => :new
  end
end
