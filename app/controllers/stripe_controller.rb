class StripeController < ApplicationController
  protect_from_forgery except: :webhook

  def webhook; end
end
