# Controller for handling the login, logout process for "users" of our
# little server.  Users have no password.  This is just an example.
require 'openid'

class LoginController < ApplicationController
  before_filter :set_locale
  layout 'index'

  def base_url
    url_for(:controller => 'login', :action => nil, :only_path => false)
  end

  def index
    response.headers['X-XRDS-Location'] = url_for({
      :controller => "server",
      :action => "idp_xrds",
      :only_path => false})

    params[:hours] ||= params[:date] ? '06-24' : Time.now.in_time_zone("Buenos Aires").strftime('%H-24')

    params[:date] ||= Time.zone.now.to_s
    params[:home] = true

    @limit, @offset = params[:page] ? 110 : 90, params[:offset].to_i
    occurrences = Occurrence.find(:all,
      :include => [:places, { :event => :category }],
      :conditions => Occurrence.conditions(params),
      :order => params[:view] == 'category' ? 'category_id, title' : nil,
      :offset => @offset,
      :limit => @limit)

    @categories = Attribute.top_categories.find(:all, :include => [:children => :children])
    @category = Attribute.find(params[:category].to_i) if params[:category].to_i > 0

    @columns = Occurrence.format(occurrences, { :flat => request.xhr?, :view => params[:view] })
    if params[:page]
      render :partial => 'column', :collection => @columns, :layout => false
    else
      if occurrences.length == @limit # Received everything as requested
        # Remove last column as incomplete most likely
        last_column = @columns.pop
        @count = last_column.nil? ? 0 : @limit - last_column.length
      end
      render :layout => !request.xhr?
    end
  end

  def submit
    username = params[:username]
    # if we get a user, log them in by putting their username in
    # the session hash.
    unless username.nil?
      session[:username] = username
      session[:approvals] = []
      unless (user = User.find_by_name(username)).nil?
        session[:user_id] = user.id
      end
      flash[:notice] = "Your OpenID URL is <b>#{base_url}user/#{user}</b><br/><br/>Proceed to step 2 below."
    else
      flash[:error] = "Sorry, couldn't log you in. Try again."
    end

    redirect_to :action => 'index'
  end

  def logout
    session[:user] = nil
    session[:openid_identifier] = nil
    session[:username] = nil
    session[:approvals] = nil
    session[:open_id] = nil
    redirect_to :action => 'index'
  end

protected
  def category
    category_id = (params[:category] || params[:sub_category] || params[:top_category]).to_i
    @category = Attribute.find(category_id, :include => [:children => :children, :parent => :parent]) unless category_id == 0
  end
end
