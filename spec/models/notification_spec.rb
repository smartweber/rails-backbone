require 'rails_helper'
require 'rabl_helper'

RSpec.describe Notification, type: :model do
  let!(:user)                { create(:user) }
  let!(:other_user)          { create(:user) }
  let!(:chat)                { create(:chat) }
  let(:message_notification) { create(:message_notification, notifiable: chat.messages.last, user_id: chat.messages.last.participant.user_id) }

  describe ".new_message" do
    it do
      expect{ Notification.new_message(chat.messages.last.participant.user_id, chat.messages.last.id) }.to change(Notification, :count).by(1)
    end

    it "sends push notification" do
      expect_any_instance_of(Faye::Client).to receive(:publish)
        .with("/api/users/#{chat.messages.first.participant.user_id}/notifications",
          RablHelper.render('api/users/notifications/_notification', message_notification))
      allow(Notification).to receive(:create) { message_notification }
      Notification.new_message(chat.messages.last.participant.user_id, chat.messages.last.id)
    end
  end

  describe "#other_recent_activity_participants" do
    context "when activity is 'Following'" do
      let!(:recent_follower_notification) { create(:follower_notification, user: user, created_at: Time.now.advance(minutes: -1)) }
      let!(:follower_notification) { create(:follower_notification, user: user) }
      let!(:not_recent_follower_notification) { create(:follower_notification, user: user, created_at: Time.now.advance(hours: -13)) }

      it { expect(follower_notification.other_recent_activity_participants).to include(recent_follower_notification.notifiable) }
      it { expect(follower_notification.other_recent_activity_participants).not_to include(not_recent_follower_notification.notifiable, follower_notification.notifiable) }
    end

    context "when activity is 'Liking'" do
      let!(:recent_like_notification) { create(:like_notification, user: user, created_at: Time.now.advance(minutes: -1)) }
      let!(:like_notification) { create(:like_notification, user: user) }
      let!(:not_recent_like_notification) { create(:like_notification, user: user, created_at: Time.now.advance(hours: -13)) }

      it { expect(like_notification.other_recent_activity_participants).to include(recent_like_notification.notifiable.user) }
      it { expect(like_notification.other_recent_activity_participants).not_to include(not_recent_like_notification.notifiable.user, like_notification.notifiable.user) }
    end

    context "when activity is 'Commenting'" do
      let!(:recent_comment_notification) { create(:comment_notification, user: user, created_at: Time.now.advance(minutes: -1)) }
      let!(:comment_notification) { create(:comment_notification, user: user) }
      let!(:not_recent_comment_notification) { create(:comment_notification, user: user, created_at: Time.now.advance(hours: -13)) }

      it { expect(comment_notification.other_recent_activity_participants).to include(recent_comment_notification.notifiable) }
      it { expect(comment_notification.other_recent_activity_participants).not_to include(not_recent_comment_notification.notifiable, comment_notification.notifiable) }
    end
  end

  describe ".mark_previous_notifications_as_seen" do
    context "when notification_type is message" do
      before do
        create_list(:message_notification, 2, notifiable: chat.messages.last, user_id: chat.messages.last.participant.user_id)
      end

      it "updates previous notifications seen attribute when the last notification changed" do
        expect(Notification.unseen.count).to be_eql(2)
        Notification.last.update_attributes({seen: true})
        expect(Notification.unseen.count).to be_eql(0)
      end
    end

    context "when notification_type is NOT message" do
      before do
        create_list(:follower_notification, 2, notifiable: other_user, user_id: user.id)
      end

      it "marks previous notification as seen after same type notification is created" do
        expect(Notification.unseen.count).to be_eql(1)
      end
    end
  end
end
