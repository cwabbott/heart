module Heart
  module ApplicationHelper
    
    def current_route?(controller_action)
      if /#/.match(controller_action)
        "current" if "#{controller_name}##{action_name}" == controller_action
      else
        "current" if controller_name == controller_action
      end
    end
    
    def button_to_function(name, function=nil, html_options={})
      onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function};"
      tag(:input, html_options.merge(:type => 'button', :value => name, :onclick => onclick))
    end
    
  end
end
