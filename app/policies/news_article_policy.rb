class NewsArticlePolicy < ApplicationPolicy

  def create?
    false
  end

  def destroy?
    false
  end

  def permitted_attributes
    []
  end

  class Scope < Scope
    def resolve
      scope.market_headlines
    end
  end
end
