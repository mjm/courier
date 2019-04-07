class HooksController < ApplicationController
  def webhook
    Feed.by_home_page(params[:url]).each(&:refresh)
    render text: 'Refreshed!'
  end
end
