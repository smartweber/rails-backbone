class LikePolicy < ApplicationPolicy

  def create?
    if record.likeable
      record.likeable.visible_for?(user)
    else
      true
    end
  end

  def destroy?
    record_owned_by_user?
  end

  def permitted_attributes
    [:likeable_id, :likeable_type]
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
