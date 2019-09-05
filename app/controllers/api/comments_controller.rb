class Api::CommentsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_comment, only: [:update, :destroy]
  after_action  :verify_authorized, except: [:index]

  # POST /comments
  def create
    @comment = Comment.new(permitted_attributes(Comment.new).merge(user_id: current_user.id))
    authorize @comment

    if @comment.save
      render 'create', status: 201
    else
      render(json: {errors: @comment.errors.messages}, status: 400)
    end
  end

  # DELETE /comments/1
  def destroy
    authorize @comment
    @comment.mark_for_destroy
    render json: {}, status: 204
  end

  def index
    @commentable_type = params[:commentable_type]
    @commentable_id   = params[:commentable_id]
    @comments = Comment.includes(:user, :attachments).where(commentable_id: @commentable_id, commentable_type: @commentable_type)
  end

  private
    def set_comment
      @comment = Comment.find(params[:id])
    end
end
