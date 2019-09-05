require 'rails_helper'

describe MessagePolicy do

  let(:user) { create(:user) }
  let(:chat) { create(:chat) }

  subject { described_class }

  permissions :create? do

    it "grants access to user that is a participant in a chat" do
      expect(subject).to permit(chat.participants.first.user, Message.new(chat_id: chat.id))
    end

    it "denies access to user that is NOT a participant in a chat" do
      expect(subject).not_to permit(user, Message.new(chat_id: chat.id))
    end
  end
end
