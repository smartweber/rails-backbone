require 'rails_helper'

describe CompanyPolicy do

  let(:user) { User.new }

  subject { described_class }

  permissions :show? do
    it "grants access" do
      expect(subject).to permit(user, Company.new)
    end
  end
end
