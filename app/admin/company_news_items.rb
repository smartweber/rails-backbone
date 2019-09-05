ActiveAdmin.register CompanyNewsItem, as: 'CompanyNews' do
  config.sort_order = 'published_at_desc' # assumes you are using 'position' for your acts_as_list column
  config.per_page = 50
  sortable # creates the controller action which handles the sorting

  permit_params :title, :news_thumbnail, :position

  scope("All") { |scope| scope.order('published_at DESC') }
  scope "By Position", :asc_by_position

  index do
    sortable_handle_column
    selectable_column
    id_column
    column :position
    column :title
    column :trending_until
    column :published_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :position
      row :title
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
    end
    active_admin_comments
  end

  filter :title
  filter :published_at

  form do |f|
    f.semantic_errors *f.object.errors.keys
    inputs 'Details' do
      input :title
      input :news_thumbnail, hint: image_tag(f.object.news_thumbnail_carousel_list_url)
      input :position
    end
    actions
  end
end
