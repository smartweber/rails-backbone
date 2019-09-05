require 'rails_helper'

RSpec.describe Api::CommentsController, :type => :controller do

  let(:user)          { FactoryGirl.create(:user) }
  let(:existing_post) { create(:post) }
  # This should return the minimal set of attributes required to create a valid
  # Comment. As you add validations to Comment, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "body" => "lorem", "commentable_id" => existing_post.id,
                             "commentable_type" => "Post" } }
  let(:invalid_attributes) { {"body" => "" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # CommentsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before { sign_in user }

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Comment" do
        expect {
          post :create, {:comment => valid_attributes, format: :json}, valid_session
        }.to change(Comment, :count).by(1)
      end

      it "assigns a newly created comment as @comment" do
        post :create, {:comment => valid_attributes, format: :json}, valid_session
        expect(assigns(:comment)).to be_a(Comment)
        expect(assigns(:comment)).to be_persisted
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved comment as @comment" do
        post :create, {:comment => invalid_attributes, format: :json}, valid_session
        expect(assigns(:comment)).to be_a_new(Comment)
      end
    end
  end

  context do
    before { @comment = Comment.create! valid_attributes.merge({user_id: user.id}) }

    # describe "PUT update" do
    #   it "updates record" do
    #     put :update, {id: @comment.to_param, comment: valid_attributes, format: :json}, valid_session
    #     expect(assigns(:comment)).to be_persisted
    #   end
    # end

    describe "DELETE destroy" do
      it "destroys the requested comment" do
        expect {
          delete :destroy, {:id => @comment.to_param, format: :json}, valid_session
        }.to change(Comment, :count).by(-1)
      end
    end
  end

end
