class FriendshipPolicy < ApplicationPolicy
  def destroy?
    record_owned_by_user?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
