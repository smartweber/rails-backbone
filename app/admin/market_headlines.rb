ActiveAdmin.register MarketHeadline, as: 'MarketHeadlines' do
  config.sort_order = 'created_at_desc'
  config.per_page = 50
  sortable # creates the controller action which handles the sorting

  permit_params :title, :position

  index do
    sortable_handle_column
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
      row :created_at
      row :updated_at
      row :trending_until
    end
    active_admin_comments
  end

  filter :title
  filter :published_at

  form do |f|
    f.semantic_errors *f.object.errors.keys
    inputs 'Details' do
      input :title
      input :position
    end
    actions
  end
end
