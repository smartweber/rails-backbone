require 'rails_helper'

describe RelationshipPolicy do

  let(:user) { User.new }

  subject { described_class }

  permissions ".scope" do
    it "returns a pure scope" do
      expect(subject::Scope.new(user, Relationship).resolve).to be_eql(Relationship)
    end
  end
end
