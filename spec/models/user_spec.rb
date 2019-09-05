require 'rails_helper'

RSpec.describe User do

  it { is_expected.to validate_inclusion_of(:experience).in_array(User::EXPERIENCES) }
  it { is_expected.to validate_inclusion_of(:primary_investment_strategy).in_array(User::PRIMARY_INVESTMENT_STRATEGIES) }
  it { is_expected.to validate_inclusion_of(:average_investment_period).in_array(User::AVERAGE_INVESTMENT_PERIODS) }

  before do
    @user = User.new(name: "Example User", email: "user@example.com", username: 'example',
                     password: "password", password_confirmation: "password", tos_and_pp_accepted: true)
  end

  subject { @user }

  it { should be_valid }

  describe "when validating name" do

    let(:multi_words) { FactoryGirl.create(:user, name: 'Shashi Singh') }
    let(:words_with_symbols) { build(:user, name: "M'r. Sh'ashi Si-ngh.") }
    let(:single_word) { build(:user, name: 'Shashi') }
    let(:with_invalid_symbol) { build(:user, name: 'Shashi $ingh') }
    let(:following_delimiters) { build(:user, name: 'Steve Smi-.th') }

    it "validates name with more than one words" do
      expect(multi_words).to be_valid
    end
    it "validates name with allowed symbols(dot, dash, apostrophe) " do
      expect(words_with_symbols).to be_valid
    end
    it "does validate name with single word" do
      expect(single_word).to be_valid
    end
    it "does not validate name which contain symbols that are not allowed" do
      expect(with_invalid_symbol).to be_invalid
    end
    it "does not validate name in which two 'delimiters' follow each other" do
      expect(following_delimiters).to be_invalid
    end

  end

  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@example,com user_at_foo.org user.name@example.
        foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when name is not unique" do
    before { @user = create(:user) }
    before { @other_user = build(:user, name: @user.name) }

    it do
      @other_user.save
      expect(@other_user).to be_invalid
    end
  end

  describe "when name is not following format" do
    before { @valid_user = build(:user) }
    before { @invalid_user1 = build(:user, name: '42') }

    it do
      expect(@invalid_user1).to be_invalid
      expect(@valid_user).to be_valid
    end
  end

  describe "username validation" do
    let(:valid_user1) { build(:user) }
    let(:valid_user2) { build(:user, username: '0thIs-isValid') }
    let(:invalid_user1) { build(:user, username: 'in;valid') }
    let(:invalid_user2) { build(:user, username: 'inva.lid') }
    let(:invalid_user3) { build(:user, username: '-invalid') }

    it do
      expect(valid_user1).to be_valid
      expect(valid_user2).to be_valid
      expect(invalid_user1).to be_invalid
      expect(invalid_user2).to be_invalid
      expect(invalid_user3).to be_invalid
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "when password is not present" do
    before do
      @user = User.new(name: "Example User", email: "user@example.com",
                       password: " ", password_confirmation: " ")
    end
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 7 }
    it { should be_invalid }
  end

  describe "post associations" do

    before { @user.save }
    let!(:older_post) do
      FactoryGirl.create(:post, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_post) do
      FactoryGirl.create(:post, user: @user, created_at: 1.hour.ago)
    end

    it "should have the right posts in the right order" do
      expect(@user.posts.to_a).to eq [newer_post, older_post]
    end

    it "should destroy associated posts" do
      posts = @user.posts.to_a
      @user.destroy
      expect(posts).not_to be_empty
      posts.each do |post|
        expect(Post.where(id: post.id)).to be_empty
      end
    end

    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:post, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }

      before do
        @user.follow(followed_user)
        3.times { followed_user.posts.create!(content: "Lorem ipsum") }
      end

      its(:feed) { should include(newer_post) }
      its(:feed) { should include(older_post) }
      its(:feed) { should_not include(unfollowed_post) }
      its(:feed) do
        followed_user.posts.each do |post|
          should include(post)
        end
      end
    end
  end

  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow(other_user)
    end

    it { should be_following_user(other_user) }
    its(:following_users) { should include(other_user) }

    describe "followed user" do
      subject { other_user }
      its(:followers) { should include(@user) }
    end

    describe "and unfollowing" do
      before { @user.unfollow(other_user) }

      it { should_not be_following_user(other_user) }
      its(:following_users) { should_not include(other_user) }
    end
  end

  describe "methods" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    describe ".follow" do

      context "when receiving request" do
        it do
          expect( NotificationWorker ).to receive(:new_follower).with(user.id, other_user.id)
          user.follow(other_user)
        end
      end

      context "when following back" do
        before { user.follow(other_user) }
        it do
          expect( NotificationWorker ).to receive(:new_follower).with(other_user.id, user.id)
          other_user.follow(user)
        end
      end

      it do
        user.follow(other_user)
        other_user.follow(user)
        expect( user.mutually_following?(other_user) ).to be true
      end
      it { expect{ user.follow(other_user) }.to change(Relationship, :count).by(1) }
    end

    describe ".unfollow" do
      before { user.follow(other_user) }
      before { other_user.follow(user) }

      it do
        user.unfollow(other_user)
        expect( user.mutually_following?(other_user) ).to be false
      end
      it { expect{ user.unfollow(other_user) }.to change(Relationship, :count).by(-1) }
    end

    describe ".mutually_following?" do
      before { user.follow(other_user) }
      before { other_user.follow(user) }
      let(:another_user) { create(:user) }

      it { expect( user.mutually_following?(other_user) ).to be true }
      it { expect( user.mutually_following?(another_user) ).to be false }
    end

    describe ".mutual_relationships" do
      let(:another_user) { create(:user) }
      let(:following_user) { create(:user) }

      before { following_user.follow(user) }
      before { user.follow(other_user) }
      before { user.follow(another_user) }
      before { other_user.follow(user) }

      it { expect(user.mutual_relationships.map(&:follower)).to include(other_user) }
      it { expect(user.mutual_relationships.map(&:follower)).to_not include(following_user) }
      it { expect(user.mutual_relationships.map(&:follower)).to_not include(another_user) }
    end

    describe ".visible_posts_for" do
      let!(:public_post)      { create(:post, user: user) }
      let!(:private_post)     { create(:post, user: user, friends_only: true) }
      let!(:friend_user)      { create(:user) }
      let!(:another_user)     { create(:user) }

      before do
        user.follow(friend_user)
        friend_user.follow(user)
      end

      context "for user that's NOT followed back" do
        it "does NOT return private posts" do
          expect(user.visible_posts_for(another_user)).to_not include(private_post)
        end
        it "returns public posts" do
          expect(user.visible_posts_for(another_user)).to include(public_post)
        end
      end
      context "for user that's followed back" do
        it "returns private posts" do
          expect(user.visible_posts_for(friend_user)).to include(private_post)
        end
        it "returns public posts" do
          expect(user.visible_posts_for(friend_user)).to include(public_post)
        end
      end
    end

    describe ".feed_posts" do
      let!(:followed_company)    { create(:company) }
      let!(:company_post)        { create(:post, content: "$#{followed_company.abbr} related") }
      let!(:public_post)         { create(:post, user: user) }
      let!(:private_post)        { create(:post, user: user, friends_only: true) }
      let!(:random_public_post)  { create(:post) }
      let!(:random_private_post) { create(:post, friends_only: true) }
      let!(:friend_user)         { create(:user) }
      let!(:followed_user)       { create(:user) }
      let!(:following_user)      { create(:user) }
      let!(:public_post_by_followed_user) { create(:post, user: followed_user) }
      let!(:public_post_by_following_user) { create(:post, user: following_user) }
      let!(:private_post_by_followed_user) { create(:post, user: followed_user, friends_only: true) }
      let!(:private_post_by_friend_user) { create(:post, user: friend_user, friends_only: true) }

      before do
        following_user.follow(user)
        user.follow(followed_company)
        user.follow(followed_user)
        user.follow(friend_user)
        friend_user.follow(user)
      end

      it "does NOT return posts from users that I don't follow" do
        expect(user.feed_posts).to_not include(random_public_post)
        expect(user.feed_posts).to_not include(random_private_post)
      end
      it "returns private posts of friends users" do
        expect(user.feed_posts).to include(private_post_by_friend_user)
      end
      it "does NOT return private posts of followed users" do
        expect(user.feed_posts).to_not include(private_post_by_followed_user)
      end
      it "does NOT return public posts of following users" do
        expect(user.feed_posts).to_not include(public_post_by_following_user)
      end
      it "returns public posts from followed entities" do
        expect(user.feed_posts).to include(company_post)
        expect(user.feed_posts).to include(public_post_by_followed_user)
      end
    end
  end
end
