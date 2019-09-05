class MessagePolicy < ApplicationPolicy
  def create?
    record.chat.participants.where(user_id: user.id).any?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
