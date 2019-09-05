require 'rails_helper'

RSpec.describe Api::RelationshipsController, type: :controller do

  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  before { sign_in user }

  describe "POST #create" do

    it "saves Relationship" do
      expect do
        xhr :post, :create, followable_type: 'User', followable_id: other_user.id, format: :json
      end.to change(Relationship, :count).by(1)
    end

    it "responds with success" do
      xhr :post, :create, followable_type: 'User', followable_id: other_user.id, format: :json
      expect(response).to be_success
    end
  end

  describe "DELETE #destroy" do

    before { user.follow(other_user) }
    let(:relationship) do
      user.active_relationships.find_by(followable_id: other_user.id, followable_type: 'User')
    end

    it "destroys Relationship" do
      expect do
        xhr :delete, :destroy, id: relationship.id, format: :json
      end.to change(Relationship, :count).by(-1)
    end

    it "responds with success" do
      xhr :delete, :destroy, id: relationship.id, format: :json
      expect(response).to be_success
    end
  end
end
