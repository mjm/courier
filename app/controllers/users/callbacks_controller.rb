class Users::CallbacksController < Devise::OmniauthCallbacksController
  def twitter
    @user = User.from_omniauth(request.env['omniauth.auth'])
    raise 'User is not allowed to login' if @user.blank?

    cookies.encrypted[:user_id] = @user.id # for the ActionCable connection
    sign_in_and_redirect @user, event: :authentication
  end
end
