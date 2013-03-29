class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale

  include AuthenticationHelper

  def current_user
    User.new(:id => 1)
  end
  helper_method :current_user

  private

  def login_required
  end

  def set_locale
    if !params[:lang].nil?
      supported_locales ||= I18n.available_locales.map {|x| x.to_s}
      if supported_locales.include?(params[:lang])
        cookies.permanent[:lang] = params[:lang]
      end
    end
    cookies.permanent[:lang] = "en" if cookies[:lang].nil?
    I18n.locale = cookies[:lang]
    return true
  end
end
