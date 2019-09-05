require 'acceptance_helper'

resource 'Users', type: :acceptance do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let!(:user) { create(:user) }

  context 'signed in' do
    before do
      no_doc do
        client.post '/login.json', user: { email: user.email, password: user.password }
      end
    end

    get '/api/users' do
      parameter :query, 'Beggining of User\'s username'
      parameter :page, 'If query parameter is not present - page is used for simple pagination'

      response_field :id, 'User id'
      response_field :name, 'User name'
      response_field :username, 'User username'
      response_field :gravatar_url, 'User\'s gravatar image url'
      response_field :followers_count, 'Amount of users that following this user'
      response_field :target_url, 'Url to user\'s page'

      let(:query) { user.username.first(1) }
      let(:page)  { 1 }

      example 'Retrieve list of users for autocomplete' do
        do_request(page: nil)
        expect(status).to eq(200)
        expect( json.first['id'] ).to be_eql(user.id)
        expect( json.first['name'] ).to be_eql(user.name)
        expect( json.first['username'] ).to be_eql(user.username)
        expect( json.first['followers_count'] ).to be_eql(user.followers_count)
      end

      example 'Retrieve paginated list of users' do
        do_request(query: nil)
        expect(status).to eq(200)
        expect( json.first['id'] ).to be_eql(user.id)
        expect( json.first['name'] ).to be_eql(user.name)
        expect( json.first['username'] ).to be_eql(user.username)
        expect( json.first['followers_count'] ).to be_eql(user.followers_count)
      end
    end

    put '/api/users/:id' do
      parameter :id, 'ID of User to retrieve', required: true
      parameter :avatar, 'User\'s avatar', scope: :user
      parameter :filename, 'Avatar\'s filename', scope: :user

      response_field :id, 'User id'
      response_field :name, 'User name'
      response_field :username, 'User username'
      response_field :gravatar_url, 'User\'s gravatar image url'
      response_field :email, 'User email'
      response_field :created_at, 'DateTime at which user registered'
      response_field :following_users_count, 'Amount of users that this user is following'
      response_field :followers_count, 'Amount of users that following this user'
      response_field 'relationship[id]', 'Relationship id(following entity, destroy to unfollow)'
      response_field 'friendship[id]', 'Friendship id(friendship entity, destroy to unfriend)'

      let(:id) { user.id }
      let(:avatar) { Rack::Test::UploadedFile.new('spec/fixtures/image.png') }
      let(:filename) { 'image.png' }

      example_request 'Update user' do
        expect(status).to eq(200)
      end
    end

    get '/api/users/:id' do
      parameter :id, 'Username of User to retrieve', required: true

      response_field :id, 'User id'
      response_field :name, 'User name'
      response_field :username, 'User username'
      response_field :gravatar_url, 'User\'s gravatar image url'
      response_field :email, 'User email'
      response_field :created_at, 'DateTime at which user registered'
      response_field :following_users_count, 'Amount of users that this user is following'
      response_field :followers_count, 'Amount of users that following this user'
      response_field 'relationship[id]', 'Relationship id(following entity, destroy to unfollow)'
      response_field 'friendship[id]', 'Friendship id(friendship entity, destroy to unfriend)'
      response_field 'notifications[type]', 'Type of notification'
      response_field 'notifications[arr]', 'Array of notifications'

      let(:id) { user.username }

      example_request 'Getting a specific User' do
        expect(status).to eq(200)
        expect( json['id'] ).to be_eql(user.id)
        expect( json['name'] ).to be_eql(user.name)
        expect( json['username'] ).to be_eql(user.username)
        expect( json['email'] ).to be_eql(user.email)
        expect( json['following_companies_count'] ).to be_eql(user.following_companies_count)
        expect( json['following_users_count'] ).to be_eql(user.following_users_count)
        expect( json['followers_count'] ).to be_eql(user.followers_count)
        expect( json['relationship'] ).to be_nil
        expect( json['friendship'] ).to be_nil
      end

      example 'Getting a non existing User', document: false do
        do_request(id: 'invalid')
        expect(status).to eq(404)
      end
    end
  end
end
