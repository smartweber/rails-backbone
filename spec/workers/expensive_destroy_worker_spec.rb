require "rails_helper"

describe ExpensiveDestroyWorker, type: :model do

  describe "#expensive_destroy" do
    let!(:post) { create(:post) }

    it do
      expect {
        ExpensiveDestroyWorker.perform_async('expensive_destroy', 'Post', post.id)
      }.to change(ExpensiveDestroyWorker.jobs, :size).by(1)
    end

    it "destroys object" do
      ExpensiveDestroyWorker.perform_async('expensive_destroy', 'Post', post.id)
      expect{ExpensiveDestroyWorker.drain}.to change(Post, :count).by(-1)
    end
  end
end
