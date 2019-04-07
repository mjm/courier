class HooksController < ApplicationController
  def webhook
    logger.info "Got webhook: #{params.inspect}"
  end
end
