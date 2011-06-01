class SessionController < ApplicationController
    def create
      if open_id?(params[:name])
        open_id_authentication(params[:name])
      else
        password_authentication(params[:name], params[:password])
      end
    end

    protected
      def password_authentication(name, password)
        if @current_user = @account.users.find_by_name_and_password(params[:name], params[:password])
          successful_login
        else
          failed_login "Sorry, that username/password doesn't work"
        end
      end

      def open_id_authentication(identity_url)
        authenticate_with_open_id(identity_url) do |status, identity_url|
          case status
          when :missing
            failed_login "Sorry, the OpenID server couldn't be found"
          when :canceled
            failed_login "OpenID verification was canceled"
          when :failed
            failed_login "Sorry, the OpenID verification failed"
          when :successful
            if @current_user = @account.users.find_by_identity_url(identity_url)
              successful_login
            else
              failed_login "Sorry, no user by that identity URL exists"
            end
          end
        end
      end

    private
      def successful_login
        session[:user_id] = @current_user.id
        redirect_to(root_url)
      end

      def failed_login(message)
        flash[:error] = message
        redirect_to(new_session_url)
      end

      # Set #root_url if your root url has a different named route.
      #
      #   map.home '', :controller => ..., :action => ...
      #
      # Otherwise, name the route 'root' and leave this method out.
      def root_url
        home_url
      end
  end
