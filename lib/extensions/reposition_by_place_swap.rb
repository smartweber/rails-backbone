module RepositionByPlaceSwap
  extend ActiveSupport::Concern

  included do
    before_save :position_swap, if: 'self.position_changed?'

    def position_swap
      previous_item = self.class.where(position: self.position).first
      previous_item.update_columns(position: nil, trending_until: nil) if previous_item
    end
  end
end
