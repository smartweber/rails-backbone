require 'rails_helper'

describe ChatPolicy do

  let(:chat) { create(:chat) }
  let!(:other_chat) { create(:chat) }

  subject { described_class }

  permissions ".scope" do
    it "returns a user scoped chats" do
      expect(subject::Scope.new(chat.participants.first.user, Chat).resolve.to_a).to be_eql([chat])
    end
  end
end
