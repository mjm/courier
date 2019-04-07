class HooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    Feed.by_home_page(params[:url]).each(&:refresh)
    render plain: 'Refreshed!'
  end
end
