module ServiceHelper
  def require_user(env)
    if env[:user]
      yield env[:user]
    else
      Twirp::Error.unauthenticated 'You are not logged in.'
    end
  end
end
