class AllowedUsers
  attr_reader :users, :logger

  def initialize(env = ENV, logger: Rails.logger)
    user_string = env.fetch('ALLOWED_TWITTER_USERS', '').downcase
    @users = user_string.split(',')

    if users.empty?
      logger.info 'Allowing all Twitter users'
    else
      logger.info "Only allowing Twitter users: #{users.join(' ')}"
    end
  end

  def include?(username)
    if users.empty?
      true
    else
      users.include?(username)
    end
  end
end
