class Api::ChatsController < ApplicationController
  before_action :authenticate_user!
  after_action  :verify_policy_scoped, only: :index

  def index
    @chats = policy_scope(Chat)
    respond_to do |f|
      f.html
      f.json
    end
  end
end
