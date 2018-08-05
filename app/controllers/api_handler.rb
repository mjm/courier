class ApiHandler
  def translate(req, env)
    forward translator.translate(req)
  end

  private

  def forward(resp)
    resp.data || resp.error
  end

  def translator
    Courier::TranslatorClient.connect
  end
end
