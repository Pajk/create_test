class CreateTestController < ApplicationController
  unloadable

  before_filter :find_project, :only => [:new]
  before_filter :check_for_default_issue_status, :only => [:new]
  before_filter :build_new_issue_from_params, :only => [:new]


  def new
    respond_to do |format|
      format.html { render :action => 'new', :layout => !request.xhr? }
    end
  end

  private

  def find_project
    project_id = params[:project_id] || (params[:issue] && params[:issue][:project_id])
    @project = Project.find(project_id)
    unless @project.module_enabled?('create_test')
      raise ActiveRecord::RecordNotFound.new
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def build_new_issue_from_params
    if params[:id].blank?
      @issue = Issue.new
      if params[:copy_from]
        begin
          @copy_from = Issue.visible.find(params[:copy_from])
          @copy_attachments = params[:copy_attachments].present? || request.get?
          @copy_subtasks = params[:copy_subtasks].present? || request.get?
          @issue.copy_from(@copy_from, :attachments => @copy_attachments, :subtasks => @copy_subtasks)
          @issue.estimated_hours = nil
          @issue.done_ratio = nil
          @issue.start_date = nil
          @issue.due_date = nil
          @issue.assigned_to = nil
          @issue.status = IssueStatus.default
          tracker = Tracker.find_or_create_by_name('Test')

          unless @project.trackers.include?(tracker)
            @project.trackers << tracker
            @project.save!
          end

          @issue.tracker = tracker
        rescue ActiveRecord::RecordNotFound
          render_404
          return
        end
      end
      @issue.project = @project
    else
      @issue = @project.issues.visible.find(params[:id])
    end

    @issue.project = @project
    @issue.author ||= User.current
    # Tracker must be set before custom field values
    @issue.tracker ||= @project.trackers.find((params[:issue] && params[:issue][:tracker_id]) || params[:tracker_id] || :first)
    if @issue.tracker.nil?
      render_error l(:error_no_tracker_in_project)
      return false
    end
    @issue.start_date ||= Date.today if Setting.default_issue_start_date_to_creation_date?
    @issue.safe_attributes = params[:issue]

    @priorities = IssuePriority.active
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current, true)
  end

  def check_for_default_issue_status
    if IssueStatus.default.nil?
      render_error l(:error_no_default_issue_status)
      return false
    end
  end
end
