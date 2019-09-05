ActiveAdmin.register AdminUserAttachment do
  actions :all
  config.per_page = 50
  permit_params :image, :title, :description, :file

  filter :title
  filter :description

  controller do
    def create
      @attachment = AdminUserAttachment.new(permitted_params[:attachment])
      @attachment.admin_user_id = current_admin_user.id
      @attachment.image = params[:file]
      if @attachment.save
        render json: {
          image: {
            url: @attachment.image.url
          }
        }, content_type: "text/html"
      else
        head :bad_request
      end
    end
  end
end
