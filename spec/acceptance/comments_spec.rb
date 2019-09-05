require 'acceptance_helper'

resource 'Comments', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)      { create(:user) }
  let!(:post)      { create(:post) }
  let!(:comment)   { create(:comment, commentable: post, user: user) }
  let!(:user_attachment) { create(:link_attachment, attachable: comment, user: user) }

  context 'signed in' do
    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    post '/api/comments' do
      let(:comment_body) { Faker::Lorem.sentence }
      # TODO: response cleanup
      parameter :body, 'Comment content', required: true
      parameter :commentable_id, 'ID of the object which will nest a comment', required: true
      parameter :commentable_type, 'Type of the object which will nest a comment', required: true
      parameter :reply_to_comment_id, 'ID of the comment that this comment replies to'
      parameter :user_attachment_id, 'ID of the attachment that to be embedded into comment'

      response_field :id, 'Comment id'
      response_field :commentable_id, 'Commentable object id'
      response_field :commentable_type, 'Commentable object type'
      response_field :created_at, 'DateTime when comment was created'
      response_field :reply_to_comment_id, 'Id of comment to which this comment is replying'
      response_field :user_id, 'Id of user that created comment'
      response_field :likes_count, 'Cached amount of likes'
      response_field :body, 'Content of the comment'
      response_field :like, 'DEPRECATED'
      response_field 'user[id]', 'User id'
      response_field 'user[email]', 'User email'
      response_field 'user[created_at]', 'Date of registration'
      response_field 'user[username]', 'Username'
      response_field 'user[following_users_count]', 'Number of users that this user following'
      response_field 'user[followers_count]', 'Number of users that following this user'
      response_field 'user[name]', 'Full name'
      response_field 'user[gravatar_url]', 'URL to gravatar image'
      response_field 'user[collections_count]', 'Amount of collections'
      response_field 'user[ideas_count]', 'Amount of ideas(posts etc.)'
      response_field 'user[relationship]', 'DEPRECATED'
      response_field 'user[friendship]', 'DEPRECATED'
      response_field 'attachments[][id]', 'Attachment ID'
      response_field 'attachments[][type_of_attachment]', "'link'"
      response_field 'attachments[][image_url]', 'Link to page preview image'
      response_field 'attachments[][title]', 'Page title'
      response_field 'attachments[][description]', 'Page description'
      response_field 'attachments[][user_id]', 'Creator ID'

      context "with valid params" do
        let(:raw_post) do
          {
            comment: {
              body: comment_body,
              commentable_id: post.id,
              commentable_type: 'Post',
              attachment_ids: [ user_attachment.id ]
            }
          }.to_json
        end
        # TODO: figure out better solution
        let(:user_attributes) do
          user.attributes.extract!('email', 'username', 'id', 'name')
              .merge({'collections_count' => user.collections_count, 'ideas_count' => user.ideas_count, 'following_companies_count' => user.following_companies_count})
        end

        example_request "Creating a comment" do
          expect(status).to eq(201)

          expect( json['id'] ).to_not be_nil
          expect( json['commentable_id'] ).to be_eql(post.id)
          expect( json['commentable_type'] ).to be_eql('Post')
          expect( json['reply_to_comment_id'] ).to be_eql(nil)
          expect( json['user_id'] ).to be_eql(user.id)
          expect( json['likes_count'] ).to be_eql(0)
          expect( json['body'] ).to be_eql(comment_body)
          expect( json['like'] ).to be_eql(nil)
          expect( json['user'].except('gravatar_url', 'relationship', 'friendship', 'created_at', 'following_users_count', 'followers_count') ).to be_eql(user_attributes)
          expect( json['user']['following_users_count'] ).to be_eql(user.following_users_count)
          expect( json['user']['followers_count'] ).to be_eql(user.followers_count)
          expect( json['attachments'].first ).to be_eql(user_attachment.attributes.extract!('id').merge({'url' => user_attachment.image.thumb.url}))
        end
      end

      context "with invalid params" do
        let(:raw_post) do
          {
            comment: {
              body: comment_body,
              commentable_type: 'Post',
            }
          }.to_json
        end

        example "Creating a comment(invalid)", document: false do
          do_request
          expect(status).to eq(400)
          expect( json['errors'] ).to_not be_empty
        end
      end
    end

    get '/api/comments' do
      parameter :commentable_id, 'ID of the object which comments are requested', required: true
      parameter :commentable_type, 'Type of the object which comments are requested', required: true

      let(:commentable_id)   { post.id }
      let(:commentable_type) { 'Post' }

      example_request "Getting a list of comments" do
        explanation "response structure is the same as at comment creation"
        expect(status).to eq(200)
      end
    end

    delete '/api/comments/:id' do
      parameter :id, 'ID of comment', required: true
      let(:id) { comment.id }

      example_request 'Delete comment' do
        expect(status).to eq(204)
      end
    end
  end
end
