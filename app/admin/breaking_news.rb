ActiveAdmin.register BreakingNews, as: 'BreakingNews' do
  permit_params :title, :trending_until, :id

  index do
    selectable_column
    id_column
    column :title
    column :updated_at
    column :trending_until
    actions
  end

  member_action :enable, method: :put do
    resource.enable!
    redirect_to collection_path, notice: "Breaking news with ID:#{resource.id} is enabled!"
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    inputs "Details" do
      input :title
      input :trending_until, as: :date_time_picker, datepicker_options: { format_date:'Y/m/d', min_date: '0', max_date: '+1970/01/03' }
    end
    actions
  end

  filter :updated_at
end
