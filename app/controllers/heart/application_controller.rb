module Heart
  class ApplicationController < ActionController::Base
    protect_from_forgery
    before_filter :set_locale
    layout 'heart_engine'

    private

    def set_locale
      if !params[:lang].nil?
        supported_locales ||= I18n.available_locales.map {|x| x.to_s}
        if supported_locales.include?("#{params[:lang]}_heart")
          cookies.permanent[:heart_lang] = params[:lang]
        end
      end
      cookies.permanent[:heart_lang] = "en" if cookies[:heart_lang].nil?
      I18n.locale = "#{cookies[:heart_lang]}_heart"
      return true
    end
  end
end
