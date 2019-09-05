require 'rails_helper'

describe FriendshipPolicy do

  let(:user) { double('User', id: 1) }

  subject { described_class }

  permissions :destroy? do
    it_behaves_like "user ownership permission"
  end
end
