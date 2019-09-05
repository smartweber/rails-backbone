class Api::UsersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_user, only: [:update]
  before_action :authorize_user, except: [:index, :show]
  after_action  :verify_authorized, except: [:index, :show]

  def show
    @user = User.find_by_username!(params[:id])

    respond_to do |format|
      format.html
      format.json { render 'show', status: 200 }
    end
  end

  def index
    if params[:query].present?
      @users = User.search_with_autocomplete(params[:query])
    else
      @users = User.page(params[:page])
    end

    respond_to do |format|
      format.html
      format.json
    end
  end

  def update
    if @user.update_attributes(user_params)
      render 'update'
    else
      render(json: {errors: @user.errors.messages}, status: 400)
    end
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def authorize_user
      authorize @user
    end

    def user_params
      params.require(:user).permit(policy(@user).permitted_attributes)
    end
end
