ActiveAdmin.register Company, as: 'Companies' do
  # Default sort order doesn't support multiple rows sorting.
  # Leave it blank with "" value and enable default scope with ordering.
  config.sort_order = ''
  config.per_page = 50

  scope "All", :asc_by_position, default: true

  permit_params :name, :abbr, :exchange, :market_cap, :position, :trending_until

  index do
    selectable_column
    id_column
    column :abbr
    column :position
    column :name
    column :trending_until
    actions
  end

  show do
    attributes_table do
      row :id
      row :position
      row :name
      row :abbr
      row :exchange
      row :market_cap
      row :created_at
      row :updated_at
      row :trending_until
    end
    active_admin_comments
  end

  filter :abbr
  filter :name
  filter :exchange

  form do |f|
    f.semantic_errors *f.object.errors.keys
    inputs 'Details' do
      input :name
      input :abbr
      input :exchange
      input :market_cap
      input :position, as: :select, collection: Company::TOP_POSITIONS
      input :trending_until, as: :date_time_picker, datepicker_options: { format_date:'Y/m/d', min_date: '0', max_date: '+1970/01/03' }
    end
    actions
  end
end
