require 'rails_helper'

RSpec.describe Relationship do

  let(:follower) { FactoryGirl.create(:user) }
  let(:followed) { FactoryGirl.create(:user) }
  let(:relationship) { follower.active_relationships.build(followable: followed) }

  subject { relationship }

  it { should be_valid }

  describe "follower methods" do
    it { should respond_to(:follower) }
    it { should respond_to(:followable) }
    its(:follower) { should eq follower }
    its(:followable) { should eq followed }
  end

  describe "when followed id is not present" do
    before { relationship.followable = nil }
    it { should_not be_valid }
  end

  describe "when follower id is not present" do
    before { relationship.follower_id = nil }
    it { should_not be_valid }
  end

  it_behaves_like "a notification trigger", :new_follower
end
