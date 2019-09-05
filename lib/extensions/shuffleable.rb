module Shuffleable
  extend ActiveSupport::Concern

  included do
    after_save :reposition, if: 'self.position_changed?'

    def reposition
      self.insert_at self.position if self.position
    end
  end
end
