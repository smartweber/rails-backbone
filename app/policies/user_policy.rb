class UserPolicy < ApplicationPolicy
  def permitted_attributes
    [:avatar]
  end

  def update?
    record_owned_by_user?
  end

  def show?
    true
  end

  def edit?
    record.id == user.id
  end

  def record_owned_by_user?
    user.id == record.id
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
