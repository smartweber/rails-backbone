require 'rails_helper'

feature "Chat", js: true do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:other_user) { FactoryGirl.create(:user) }
  let(:message_username) { other_user.username }
  let(:message_body) { "Message body" }
  before { sign_in_as user }

  context "when creating new chat" do
    describe "new message creation" do
      before { visit messages_path; click_link "Compose" }

      it "hits database" do
        expect do
          create_chat
          wait_for_ajax
        end.to change(user.chats, :count).by(1) and change(Message, :count).by(1)
      end

      it "redirects to created chat" do
        create_chat
        wait_for_ajax
        within "#chats-region" do
          expect(page).to have_content(message_body)
        end
        expect(current_path).to eql chat_path(user.chats.last.id)
      end
    end
  end

  context "when publishing message into pre-existing chat" do
    before { visit messages_path; click_link "Compose"; create_chat }

    describe "new message creation" do
      it "hits database" do
        within '.message-comment' do
          fill_in "body", with: message_body
          click_link "Send"
        end
        within "#messages-region" do
          expect(page).to have_content(message_body)
        end
      end
    end

    describe "new message creation with attachments" do
      pending
    end
  end
end

def create_chat
  fill_in 'message[username]', with: message_username
  fill_in 'message[body]', with: message_body
  click_link "Send"
end
