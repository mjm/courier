module Elm
  extend ActiveSupport::Concern

  def render_elm(pack, flags)
    flags_type = "#{pack.to_s.camelize}Flags".constantize
    @flags = flags_type.new(with_current_user(flags))
    @pack = pack.to_s
    render :show
  end

  private

  def with_current_user(flags)
    if flags.key? :user
      flags
    else
      flags.merge(user: current_user.to_message)
    end
  end
end
