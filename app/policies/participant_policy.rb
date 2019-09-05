class ParticipantPolicy < ApplicationPolicy
  def update?
    record_owned_by_user?
  end
end
