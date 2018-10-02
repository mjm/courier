module Elm
  extend ActiveSupport::Concern

  def render_elm(pack, flags)
    flags_type = "#{pack.to_s.camelize}Flags".constantize
    @flags = flags_type.new(
      flags.merge(user: current_user.to_message)
    )
    @pack = pack.to_s
    render :show
  end
end
