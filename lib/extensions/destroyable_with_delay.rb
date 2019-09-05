# @note be sure to modify requests so that ActiveRecord were not returning marked for deletion records
module DestroyableWithDelay

  extend ActiveSupport::Concern

  included do
    def mark_for_destroy
      update_attribute(:marked_for_deletion, true)
      ExpensiveDestroyWorker.perform_at(Date.tomorrow.at_end_of_day, :expensive_destroy, self.class.to_s, self.id)
    end
  end
end
