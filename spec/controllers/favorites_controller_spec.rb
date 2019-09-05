require 'rails_helper'

RSpec.describe Api::FavoritesController, type: :controller do

  let(:existing_post) { create(:post) }
  let(:user)          { create(:user) }

  describe "as signed in user" do
    before { sign_in user }

    describe "POST #create" do

      describe "with valid attributes" do

        describe "it creates a record" do
          it do
            expect {
              post :create, post_id: existing_post.id, format: :json
            }.to change(Favorite, :count).by(1)
          end
        end
      end
    end

    describe "DELETE #destroy" do
      before { user.favorite(existing_post) }

      describe "with valid attributes" do

        describe "it removes a record" do
          it do
            expect {
              delete :destroy, id: existing_post.id, format: :json
            }.to change(Favorite, :count).by(-1)
          end
        end
      end

      describe "with invalid attributes" do

        describe "it raises exception" do
          before { delete :destroy, id: existing_post.id + 1, format: :json }
          it do
            expect(response.code).to eql '404'
          end
        end
      end
    end
  end

  describe "as not signed in user" do

    describe "POST #create" do
      describe "with valid attributes" do

        describe "it return 401 status" do
          before { post :create, post_id: existing_post.id, format: :json }
          it do
            expect(response.code).to eql '401'
          end
        end
      end
    end
  end
end
