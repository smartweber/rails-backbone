class CommentPolicy < ApplicationPolicy
  def create?
    record_owned_by_user?
  end

  def update?
    record_owned_by_user?
  end

  def destroy?
    record_owned_by_user?
  end

  def permitted_attributes
    [:body, :commentable_id, :commentable_type, :reply_to_comment_id, :_destroy, {attachment_ids: []}, {attachments: []}]
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
