class NotificationPolicy < ApplicationPolicy
  def update?
    record_owned_by_user?
  end

  class Scope < Scope
    def resolve
      user.notifications
    end
  end
end
