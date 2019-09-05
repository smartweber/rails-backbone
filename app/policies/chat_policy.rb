class ChatPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      user.chats.includes(:participants => [:user])
    end
  end
end
