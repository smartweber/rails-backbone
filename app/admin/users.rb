ActiveAdmin.register User, as: 'Users' do
  permit_params :email, :password, :password_confirmation, :avatar


  controller do
    defaults finder: :find_by_username
  end

  index do
    selectable_column
    id_column
    column :email
    column :username
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column :avatar do |user|
      image_tag user.avatar.medium.url
    end
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  show do
    attributes_table do
      row :id
      row :email
      row :username
      row :current_sign_in_at
      row :sign_in_count
      row :created_at
      row :avatar do
        image_tag resource.avatar.medium.url
      end
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "User Details" do
      f.input :email
      f.input :avatar, hint: image_tag(f.object.avatar.medium.url)
    end
    f.actions
  end

end
