module PagesHelper
  def env_description
    if display_env == 'production'
      ''
    else
      "[#{display_env.capitalize}]"
    end
  end

  private

  def display_env
    ENV.fetch('DISPLAY_ENV') { Rails.env }
  end
end
