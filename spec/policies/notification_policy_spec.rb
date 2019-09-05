require 'rails_helper'

describe NotificationPolicy do

  let(:user) { double('User', id: 1) }

  subject { described_class }

  permissions ".scope" do
    let!(:notification)       { create(:message_notification) }
    let!(:other_notification) { create(:message_notification) }

    it "returns a user scoped notifications" do
      expect(subject::Scope.new(notification.user, Notification).resolve.to_a).to be_eql([notification])
    end
  end

  permissions :update? do
    it_behaves_like "user ownership permission"
  end
end
