class TweetsController < ApplicationController
  def translate
    response = translator.translate(content_html: params[:content_html])
    render json: response.data.to_h
  end

  private

  def translator
    Courier::TranslatorClient.connect
  end
end
