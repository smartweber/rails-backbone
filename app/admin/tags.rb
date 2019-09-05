ActiveAdmin.register Tag, as: 'Tags' do
  permit_params :description, :position, :mute_until

  actions :index, :show, :update, :edit

  scope "Hashtags by Position", :hashtags_by_position, default: true
  scope "Hashtags", :hashtags_only
  scope "Muted", :muted

  config.sort_order = ['position IS NULL', 'position ASC']
  config.per_page   = 50

  batch_action :destroy, false

  sortable # creates the controller action which handles the sorting

  controller do
    def find_resource
      Tag.where(word: params[:id]).first!
    end
  end

  index do
    sortable_handle_column
    selectable_column
    id_column
    column :position
    column :word
    column :taggings_count
    column :tag_type
    column :created_at
    actions
  end

  filter :tag_type, as: :select, collection: Tag::TYPES
  filter :word
  filter :created_at

  form do |f|
    f.semantic_errors *f.object.errors.keys
    inputs 'Details' do
      input :description
      input :position
      input :mute_until, as: :date_time_picker, datepicker_options: { format_date:'Y/m/d', min_date: '0', max_date: '+1970/03/03' }
    end
    actions
  end
end
