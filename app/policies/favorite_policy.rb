class FavoritePolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      user.favorited_posts
    end
  end
end
