module PagesHelper
  def display_env
    ENV.fetch('DISPLAY_ENV') { Rails.env }
  end

  def flags_json
    raw @flags.to_json # rubocop:disable Rails/OutputSafety
  end
end
