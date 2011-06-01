# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :current_user

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store

  # En el ejemplo de openid esta linea estaba comentada
  #protect_from_forgery # :secret => '09cdc16d68704ddc4a434769042a4838'

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  # filter_parameter_logging :password

  def set_locale
    I18n.locale = find_locale_for_first_language
  end

  def some
    set
    
  end

  def find_locale_for_first_language
   #accept_language = request.env['HTTP_ACCEPT_LANGUAGE'] || 'en'
   #user_language = accept_language.scan(/^[a-z]{2}/).first;
   ##I18n.available_locales.select { |y| y.to_s == user_language }.first
   ## The application seem not to work correctly with languages other than 'es' & 'en'
   ## Nevertheless, available_locales contains them
   #['es','en'].select { |y| y.to_s == user_language }.first || 'en'
   #Rails.env.test? ? 'en' : 'es' # test requires no unicode symbols because ruby 1.8 does not support it properly
    Rails.env.production? ? 'es' : 'en'
  end

  def admin_only
    return true
    return true if current_user && current_user.admin?
    flash[:error] = "Please login as admin to access the page"
    redirect_to :controller => :login, :action => :index
  end

  def current_user
    #return User.first
    return session[:user] if session[:user] # For compability purposes
    return nil unless session[:user_id]
    @current_user ||= User.find(session[:user_id])
  end

end
