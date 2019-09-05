require 'rails_helper'

RSpec.describe Post do

  let(:user) { FactoryGirl.create(:user) }
  before do
    # This code is not idiomatically correct.
    @post = Post.new(content: "Lorem ipsum", user_id: user.id)
  end

  subject { @post }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }

  describe "when user_id is not present" do
    before { @post.user_id = nil }
    it { should_not be_valid }
  end

  describe "with blank content" do
    before { @post.content = " " }
    it { should_not be_valid }
  end

  describe "with content that is too long" do
    before { @post.content = "a" * 141 }
    it { should_not be_valid }
  end

  describe "with more than 3 cashtags" do
    before { @post.content = "$one $two $three word #hashtag $four}" }
    it { should_not be_valid }
  end

  describe "with_cashtag" do
    let!(:post) { create(:post, content: '$APPL is not the same anymore. $SGS our new idol!') }
    let!(:private_post) { create(:post, content: '$APPL', friends_only: true) }

    it do
      expect(Post.with_cashtag('APPL', 1)).to include(post)
      expect(Post.with_cashtag('SGS', 1)).to include(post)
    end

    it "doesn't return friends_only posts" do
      expect(Post.with_cashtag('APPL', 1)).not_to include(private_post)
    end
  end

  describe ".cashtags" do
    let(:post) { build(:post, content: '$GOOGL and $aapl @and #also $invalidtag')}

    it "correctly finds cashtags in content" do
      expect(post.cashtags).to be_eql %w(GOOGL aapl)
    end
  end

  describe ".hashtags" do
    let(:post) { build(:post, content: '#USA and #Russia are $best @friends #forever')}

    it "correctly finds hashtags in content" do
      expect(post.hashtags).to be_eql %w(USA Russia forever)
    end
  end

  describe ".mentiontags" do
    let(:post) { build(:post, content: '@user_old and @user_new are $having their #differences')}

    it "correctly finds mentiontags in content" do
      expect(post.mentiontags).to be_eql %w(user_old user_new)
    end
  end

  describe ".increase_text_entities_counters" do
    context "on create" do
      let(:post) { create(:post, content: '#NYSE $AAPL are falling my @friend!') }

      it "creates the taggings" do
        expect{FactoryGirl.create(:post, content: '#NYSE $AAPL are falling my @friend!')}.to change(Tagging, :count).by(3)
      end

      it "creates the tags" do
        expect{post}.to change(Tag, :count).by(3)
      end
    end
  end
end
