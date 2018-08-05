class ApiHandler
  def translate(req, env)
    forward translator.translate(req)
  end

  def get_user_info(req, env)
    { username: 'foo',
      name: 'Foo McDude' }
  end

  private

  def forward(resp)
    resp.data || resp.error
  end

  def translator
    Courier::TranslatorClient.connect
  end
end
