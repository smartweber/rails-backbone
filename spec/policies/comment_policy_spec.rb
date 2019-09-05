require 'rails_helper'

describe CommentPolicy do

  let(:user) { double('User', id: 1) }

  subject { CommentPolicy }

  permissions :create? do
    it_behaves_like "user ownership permission"
  end

  permissions :update? do
    it_behaves_like "user ownership permission"
  end

  permissions :destroy? do
    it_behaves_like "user ownership permission"
  end
end
