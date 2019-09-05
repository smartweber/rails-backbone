class PostPolicy < ApplicationPolicy

  def create?
    record_owned_by_user?
  end

  def destroy?
    record_owned_by_user?
  end

  def favorite?
    record.visible_for?(user)
  end

  def unfavorite?
    true
  end

  def permitted_attributes
    [:content, :friends_only, :article_id, :article_type, {attachments: []}, {attachment_ids: []}]
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
