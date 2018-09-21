class UsersController < ServiceController
  def cancel_subscription(_req, env)
    require_user env do |user|
      user.cancel_subscription
      CancelSubscriptionResponse.new(user: user.to_message)
    end
  end
end
