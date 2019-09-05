module Mentionable
  extend ActiveSupport::Concern

  included do
    after_save :refresh_mentions

    def refresh_mentions
      current_mentions = parse_body_for_mentions
      new_mentions     = delete_outdated_mentions(current_mentions)
      new_mentions.each do |mentioned_user_id|
        Mention.create(mentionable: self, user_id: mentioned_user_id)
      end
    end

    def get_mentioned_user_ids(usernames_arr)
      User.where(username: usernames_arr).map(&:id)
    end

    def parse_body_for_mentions
      target = self.try(:body) || self.try(:content)
      target.scan(/@([a-zA-Z0-9]*)/).flatten
    end

    def delete_outdated_mentions(current_mentions)
      mentioned_user_ids = get_mentioned_user_ids(current_mentions)

      Mention.where(mentionable: self).where.not(user_id: mentioned_user_ids).each do |mention|
        mention.delete
        mentioned_user_ids -= mention.user_id unless mention.persisted?
      end

      mentioned_user_ids
    end
  end
end
