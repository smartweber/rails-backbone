require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe Api::LikesController, :type => :controller do

  let!(:comment) { create(:comment) }
  let(:user) { create(:user) }
  # This should return the minimal set of attributes required to create a valid
  # Like. As you add validations to Like, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {likeable_id: comment.id, likeable_type: comment.class.to_s}
  }

  let(:invalid_attributes) {
    {likeable_id: comment.id}
  }

  before { sign_in user }

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Like" do
        expect {
          post :create, {:like => valid_attributes, format: :json}
        }.to change(Like, :count).by(1)
      end

      it "assigns a newly created like as @like" do
        post :create, {:like => valid_attributes, format: :json}
        expect(assigns(:like)).to be_a(Like)
        expect(assigns(:like)).to be_persisted
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved like as @like" do
        post :create, {:like => invalid_attributes, format: :json}
        expect(assigns(:like)).to be_a_new(Like)
      end
    end
  end

  describe "DELETE destroy" do
    let!(:like) { create(:like, user: user) }

    it "destroys the requested like" do
      expect {
        delete :destroy, {:id => like.id, format: :json}
      }.to change(Like, :count).by(-1)
    end
  end

end