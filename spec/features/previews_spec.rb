require 'rails_helper'

feature "Previews", js: true do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { create(:post, user: user) }

  before { sign_in_as user }

  context "in Feed" do
    before { visit command_path }

    context "by pasting a direct link" do
      context "whilst new comment created" do
        context "with an image link", vcr: { cassette_name: 'image_attachment_scrape' } do
          it_behaves_like "pasteable element", :image, 'comment[body]', '.reply-attachments-region'
        end

        context "with an page link", vcr: { cassette_name: 'link_attachment_scrape' } do
          it_behaves_like "pasteable element", :link, 'comment[body]', '.reply-attachments-region'
        end
      end

      context "whilst new post created" do
        context "with an image link", vcr: { cassette_name: 'image_attachment_scrape' } do
          it_behaves_like "pasteable element", :image, 'post[content]', '.new-post-region'
        end

        context "with an page link", vcr: { cassette_name: 'link_attachment_scrape' } do
          it_behaves_like "pasteable element", :link, 'post[content]', '.new-post-region'
        end
      end
    end

    context "by attaching file via icon" do
      context "whilst new comment created" do
        it_behaves_like "attachable element", '.reply-region', 'comment[attachments][]', 'comment[body]'
      end

      context "whilst new post created" do
        it_behaves_like "attachable element", '.new-post-region', 'post[attachments][]', 'post[content]'
      end
    end
  end
end
