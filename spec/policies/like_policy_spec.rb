require 'rails_helper'

describe LikePolicy do

  let(:user) { double('User', id: 1) }

  subject { described_class }

  permissions :create? do
    it "grants access to a records with likeable object visible for current user" do
      expect(subject).to permit(user, Like.new)
    end
  end

  permissions :destroy? do
    it_behaves_like "user ownership permission"
  end
end
