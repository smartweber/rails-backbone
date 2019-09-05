require 'rails_helper'

describe FavoritePolicy do

  let(:user) { create(:user) }
  let(:post) { create(:post) }

  subject { described_class }

  permissions ".scope" do
    before { user.favorite(post) }
    it "returns a user scoped favorited_posts" do
      expect(subject::Scope.new(user, Favorite).resolve.to_a).to be_eql([post])
    end
  end
end
