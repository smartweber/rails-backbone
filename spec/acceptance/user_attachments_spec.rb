require 'acceptance_helper'

resource 'UserAttachments', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)      { create(:user) }
  let(:chat)       { create(:chat) }
  let(:message)    { build(:message) }
  let(:user_attachment) { create(:link_attachment, attachable: nil, user: user) }

  context 'signed in' do
    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    post '/api/user_attachments' do

      context "when type of attachment is a link" do
        parameter :link, 'Link to the attachment', required: true

        with_options scope: :user_attachment do |context|
          context.response_field :id, 'Attachment ID'
          context.response_field :type_of_attachment, "'link'"
          context.response_field :image_url, 'Link to page preview image'
          context.response_field :title, 'Page title'
          context.response_field :description, 'Page description'
          context.response_field :user_id, 'Creator ID'
          context.response_field :url, 'Shortened url to attachment'
          context.response_field :original_url, 'Original url'
        end

        let(:link) { 'http://google.com/' }

        context do
          before do
            expect(PreviewScrapper).to receive(:new).and_return(double('PreviewScrapper', run: true,
                  is_image: false, title: 'Google', description: 'Search Engine', image_url: nil))
          end

          example_request "Creating link attachment" do
            expect(status).to eq(200)
            expect(json['id']).to be_eql(UserAttachment.last.id)
            expect(json['type_of_attachment']).to be_eql('link')
            expect(json['image_url']).to be_eql(nil)
            expect(json['url']).to match(/#{UserAttachment.last.shortened_urls.first.unique_key}/)
            expect(json['original_url']).to be_eql(link)
          end
        end

        example "Creating link attachment(invalid)", document: false do
          do_request(link: nil)
          expect(status).to eq(400)
          expect( json['errors'] ).to_not be_empty
        end
      end

      context "when type of attachment is an image" do
        parameter :link, 'Link to the attachment', required: true

        with_options scope: :user_attachment do |context|
          context.response_field :id, 'Attachment ID'
          context.response_field :type_of_attachment, "'image'"
          context.response_field :image_url, 'Link to image attachment'
          context.response_field :user_id, 'Creator ID'
        end

        let(:link) { 'http://google.com/image.png' }
        before do
          stub_request(:any, link).
            to_return(:body => File.open(Rails.root.join('spec/fixtures/image.png')), :status => 200)
          expect(PreviewScrapper).to receive(:new).and_return(double('PreviewScrapper', run: true,
                is_image: true, image_url: link))
        end

        example_request "Creating image attachment" do
          expect(status).to eq(200)
          expect(json['id']).to be_eql(UserAttachment.last.id)
          expect(json['type_of_attachment']).to be_eql('image')
          expect(json['image_url']).to_not be_empty
        end
      end
    end

    delete '/api/user_attachments/:id' do
      parameter :id, 'ID of attachment', required: true
      let(:id) { user_attachment.id }

      example_request 'Delete attachment' do
        expect(status).to eq(204)
      end
    end
  end
end
