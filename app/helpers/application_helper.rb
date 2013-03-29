module ApplicationHelper
  def current_route?(controller_action)
    if /#/.match(controller_action)
      "current" if "#{controller_name}##{action_name}" == controller_action
    else
      "current" if controller_name == controller_action
    end
  end
end
