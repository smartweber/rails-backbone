require 'rails_helper'

RSpec.describe Chat, :type => :model do

  describe ".find_or_build" do
    before { @users = [double("User"), double("User")] }
    before { @chats = [double("Chat")] }

    context "building" do

      it "returns new chat object" do
        expect(Chat).to receive(:find_with_participants).with(@users).and_return([])
        expect(Chat).to receive(:new).and_return(@chats.first)
        expect(Chat.find_or_build(@users)).to eql @chats.first
      end
    end

    context "finding" do

      it "returns found Chat" do
        expect(Chat).to receive(:find_with_participants).with(@users).and_return(@chats)
        expect(Chat.find_or_build(@users)).to eql @chats.first
      end
    end
  end

  describe ".find_with_participants" do
    before { @chat = create(:chat) }
    before { @participating_users = @chat.participants.collect{|p| p.user } }

    it "returns found chats" do
      expect(Chat.find_with_participants( @participating_users.first, @participating_users.last ))
        .to eql [@chat]
    end
  end
end
