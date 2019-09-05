require 'rails_helper'

RSpec.describe Api::MessagesController, type: :controller do
  let(:user)           { create(:user) }
  let!(:existing_user) { create(:user) }

  before { sign_in user }

  describe "POST #create" do

    context "when creating new chat" do
      it "creates message" do
        expect{
          post :create, message: { username: existing_user.username, body: 'body' }, format: :json
        }.to change(Message, :count).by(1)
      end
    end
  end
end
