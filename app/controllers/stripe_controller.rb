class StripeController < ApplicationController
  protect_from_forgery except: %i[webhook subscribe]

  def subscribe
    current_user.subscribe(email: params[:stripeEmail],
                           source: params[:stripeToken])
    redirect_to account_url
  end
end
