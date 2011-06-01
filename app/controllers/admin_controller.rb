class AdminController < ApplicationController
  before_filter :admin_only
  layout 'index'

  def index
    render :layout => !request.xhr?
  end
end
