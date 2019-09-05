ActiveAdmin.register GeneralNewsItem, as: 'GeneralNews' do
  config.sort_order = ''
  config.per_page = 50

  permit_params :title, :summary, :news_thumbnail, :position, :thumbnail_x, :thumbnail_y, :thumbnail_w, :thumbnail_h, :locally_hosted

  scope "All", :asc_by_position_and_published_at, default: true
  scope "By Position", :asc_by_position
  scope :news_carousel
  scope "Positioned market headlines", :premoderated_market_headlines

  index do
    selectable_column
    id_column
    column :position
    column :title
    column(:summary) {|feed| feed.summary.split(/\s+/, 13+1)[0...13].join(' ') + "..."}
    column :trending_until
    column :published_at
    column :locally_hosted
    actions
  end

  show do
    attributes_table do
      row :id
      row :position
      row :title
      row :summary
      row :url do
        link_to resource.url, resource.url, target: '_blank'
      end
      row :published_at
      row :created_at
      row :updated_at
      row :trending_until
      row :news_thumbnail do
        image_tag resource.news_thumbnail_carousel_list_url
      end
      row :locally_hosted
    end
    active_admin_comments
  end

  filter :agency, as: :select
  filter :title
  filter :summary
  filter :published_at
  filter :locally_hosted

  form do |f|
    f.semantic_errors *f.object.errors.keys
    inputs 'Details' do
      input :title
      input :summary, input_html: {class: 'tinymce'}
      img id: 'jcrop_target', src: f.object.news_thumbnail.try(:url)
      with_options label: false do |context|
        context.input :thumbnail_x, input_html: {style: 'display: none;', id: 'thumbnail_x'}
        context.input :thumbnail_y, input_html: {style: 'display: none;', id: 'thumbnail_y'}
        context.input :thumbnail_w, input_html: {style: 'display: none;', id: 'thumbnail_w'}
        context.input :thumbnail_h, input_html: {style: 'display: none;', id: 'thumbnail_h'}
      end
      input :news_thumbnail, hint: image_tag(f.object.news_thumbnail_carousel_list_url), input_html: { class: 'croppable-thumbnail' }
      input :locally_hosted, as: :boolean
      input :position, min: 1
    end
    actions
  end

  controller do

    def find_resource
      GeneralNewsItem.friendly.where(slug: params[:id]).first!
    end

    def update
      general_news_item = GeneralNewsItem.friendly.find(params[:id])
      permitted_params['general_news_item'].except('news_thumbnail').each do |key, val|
        general_news_item.send("#{key}=", val)
      end
      general_news_item.news_thumbnail = permitted_params['general_news_item']['news_thumbnail']

      if general_news_item.save
        redirect_to admin_general_news_path(general_news_item)
      else
        render 'edit'
      end
    end
  end
end
