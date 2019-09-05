class StaticPagesController < ApplicationController
  def home
  end

  def help
  end

  def about
  end

  def contact
  end

  def show
    render file: "static_pages/#{params[:page]}"
  end
end
