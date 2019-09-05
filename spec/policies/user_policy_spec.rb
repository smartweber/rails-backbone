require 'rails_helper'

describe UserPolicy do

  let(:user)       { create(:user) }
  let(:other_user) { create(:user) }

  subject { described_class }

  permissions :show? do
    it "grants access" do
      expect(subject).to permit(user, other_user)
    end
  end

  permissions :edit? do
    it_behaves_like "id equality permission"
  end
end
