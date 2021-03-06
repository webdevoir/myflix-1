class SessionsController < ApplicationController
  def new
    redirect_to home_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      if user.active?
        session[:user_id] = user.id
        redirect_to home_path, success: 'You are signed in. Enjoy!'
      else
        redirect_to sign_in_path, danger: 'Your account has been suspended. Please contact customer service'
      end
    else
      redirect_to sign_in_path, danger: 'Invalid email or password.'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, success: 'You are signed out'
  end
end
