ActiveAdmin.register Article, as: 'Articles' do
  config.sort_order = ''
  config.per_page = 50

  permit_params :title, :body, :position, :trending_until, :thumbnail, :thumbnail_x, :thumbnail_y, :thumbnail_w, :thumbnail_h

  scope "All", :asc_by_position, default: true

  index do
    selectable_column
    id_column
    column :position
    column :title
    column :trending_until
    actions
  end

  show do
    attributes_table do
      row :id
      row :position
      row :title
      row :body
      row :created_at
      row :updated_at
      row :trending_until
    end
    active_admin_comments
  end

  filter :title

  action_item :preview do
    link_to 'Preview', article_path(article)
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    inputs 'Details' do
      input :title
      input :body, input_html: {class: 'tinymce'}
      img id: 'jcrop_target', src: f.object.thumbnail.try(:url)
      with_options input_html: {style: 'display: none;'}, label: false do |context|
        context.input :thumbnail_x
        context.input :thumbnail_y
        context.input :thumbnail_w
        context.input :thumbnail_h
      end
      input :thumbnail, as: :file, input_html: { class: 'croppable-thumbnail' }
      input :position
    end
    actions
  end

  controller do

    def find_resource
      Article.friendly.where(slug: params[:id]).first!
    end

    def update
      article = Article.friendly.find(params[:id])
      permitted_params['article'].except('thumbnail').each do |key, val|
        article.send("#{key}=", val)
      end
      article.thumbnail = permitted_params['article']['thumbnail']

      if article.save
        redirect_to admin_article_path(article)
      else
        render 'edit'
      end
    end
  end
end
