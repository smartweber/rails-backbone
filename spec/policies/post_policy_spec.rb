require 'rails_helper'

describe PostPolicy do

  let(:user) { double('User', id: 1) }

  subject { described_class }

  permissions :create? do
    it_behaves_like "user ownership permission"
  end

  permissions :destroy? do
    it_behaves_like "user ownership permission"
  end

  permissions :favorite? do
    it "grants access to user that is able to see record" do
      expect_any_instance_of(Post).to receive(:visible_for?).and_return(true)
      expect(subject).to permit(user, Post.new)
    end

    it "denies access to user that is NOT able to see record" do
      expect_any_instance_of(Post).to receive(:visible_for?).and_return(false)
      expect(subject).not_to permit(user, Post.new)
    end
  end

  permissions :unfavorite? do
    it "grants access" do
      expect(subject).to permit(user, Post.new)
    end
  end
end
