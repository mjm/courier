module CoreExt
  module Enumerable
    def to_message
      map(&:to_message)
    end
  end
end

Enumerable.include CoreExt::Enumerable
