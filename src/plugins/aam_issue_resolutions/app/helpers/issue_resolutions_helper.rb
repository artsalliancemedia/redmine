module IssueResolutionsHelper
  def issue_resolutions_options_for_select(issue_resolutions)
    options = []
    IssueResolution.resolution_tree(issue_resolutions) do |resolution, level|
      label = (level > 0 ? '&nbsp;' * 2 * level + '&#187; ' : '').html_safe
      label << resolution.name
      options << [label, resolution.id]
    end
    options
  end
end