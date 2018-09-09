class AuthController < Devise::OmniauthCallbacksController
  def twitter
    @user = User.from_omniauth(request.env['omniauth.auth'])

    cookies.encrypted[:user_id] = @user.id # for the ActionCable connection
    sign_in_and_redirect @user, event: :authentication
  end
end
