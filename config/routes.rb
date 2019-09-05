require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  get 'signup' => 'static_pages#home', as: :signup
  devise_for :users, controllers: { sessions: 'api/users/sessions', registrations: 'api/users/registrations', passwords: 'api/users/passwords' },
             :path => '', :path_names => {:sign_in => 'login', :sign_out => 'logout', sign_up: 'signup'}

  get 'password_resets/new'
  get 'password_resets/edit'

  root to: 'static_pages#home'
  get '/s/:page' => 'static_pages#show'
  # TODO(!!!): set a proper gag for html routes here
  get 'command' => 'static_pages#home'
  get 'users/:id' => 'static_pages#home', as: :user
  get 'messages' => 'static_pages#home'
  get 'messages/:id' => 'static_pages#home', as: :chat
  get 'c/:id' => 'static_pages#home', as: :company, constraints: { id: /[^\/]+/ }
  get 'topic/:id' => 'static_pages#home', as: :hashtag
  get 'settings' => 'static_pages#home', as: :settings
  get 'articles/:id' => 'static_pages#home', as: :article
  get 'news-articles/:id' => 'static_pages#home', as: :news_article

  namespace :api do
    namespace :subscriptions do
      get 'breaking_news' => 'static_pages#home', as: :breaking_news
      get 'c/:id' => 'static_pages#home', as: :company
      get 'streams/:id/type/:stream_type' => 'static_pages#home', as: :stream
      get 'streams/:id/type/:stream_type/friends' => 'static_pages#home', as: :friends_stream
      get 'streams/:id/type/:stream_type/shared' => 'static_pages#home', as: :shared_stream
      get 'trending_stream', as: :trending_stream
    end
    get 'breaking_news', to: 'breaking_news#show'
    devise_scope :user do
      post 'users' => 'users/registrations#create'
    end

    resources :users do
      resources :posts, only: [:index], module: 'users'
      namespace :following do
        resources :companies, only: [:index]
      end
      member do
        # utility route
        get :subscriptions
        get :notifications
        get :messages
        resources :recommendations, only: [] do
          collection do
            get :companies
            get :users
          end
        end
      end
    end
    resources :feed, only: [:index], controller: 'feed'
    resources :articles, only: [:show, :index] do
      member do
        get :feed
      end
    end
    resources :chats, only: [:new, :index, :show] do
      resources :messages, only: [:index]
    end
    resources :channels, only: [:show, :index]
    resources :messages, only: [:create, :destroy, :new]
    resources :participants, only: [:update]
    resources :notifications, only: [:update, :index]
    resources :account_activations, only: [:edit]
    resources :password_resets, only: [:new, :create, :edit, :update]
    resources :posts, only: [:create, :destroy] do
      collection do
        get :trending
      end
    end
    resources :comments, only: [:index, :create, :update, :destroy]
    resources :likes, only: [:create, :destroy]
    resources :relationships, only: [:create, :destroy]
    resources :user_attachments, only: [:create, :destroy]
    resources :companies, constraints: { id: /[^\/]+/ }, path: '/c', only: [:index, :show] do
      resources :posts, only: [:index], module: 'companies'
      resources :news, only: [:index], module: 'companies'
      collection do
        get :market_snapshot
        get :trending
      end
    end
    resources :market_headlines, only: [:index]
    resources :collection, only: [:create, :destroy, :index], as: 'favorites', controller: 'favorites'
    resources :news_articles, only: [:index, :show] do
      member do
        get :feed
      end
      collection do
        get :ranged
      end
    end
  end

  # TODO: Wrap into Devise authentication
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == 'admin' && password == 'r@nD0mString'
  end if Rails.env.staging? or Rails.env.production?
  mount Sidekiq::Web => '/sidekiq'

  get '/l/:id' => "shortener/shortened_urls#show", as: :shortened
end
