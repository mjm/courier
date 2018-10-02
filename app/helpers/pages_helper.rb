module PagesHelper
  def display_env
    ENV.fetch('DISPLAY_ENV') { Rails.env }
  end
end
