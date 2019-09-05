class RelationshipPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # TODO: needs to contain scope for blocked users
      scope
    end
  end
end
