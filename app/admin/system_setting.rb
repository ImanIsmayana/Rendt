ActiveAdmin.register SystemSetting do
  config.filters = false

  menu parent: 'Website Config'

  permit_params :name, :logo, :logo_cache, :email_sender, :listing_per_page, :maintenance_mode,
    :maintenance_message, presence: true

  actions :all, except: [:new, :create, :destroy]

  index do
    column :id
    column :website_name do |system_setting|
      system_setting.name
    end

    column :website_logo do |system_setting|
      image_tag system_setting.logo.url(:thumb)
    end

    column :email_sender
    column :listing_per_page
    column :maintenance_mode
    column :maintenance_message
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs "System Setting" do
      f.input :name

      f.input :logo, as: :file, hint: f.object.logo_uploader_hint.html_safe
      f.input :logo_cache, as: :hidden

      f.input :email_sender, as: :email
      f.input :listing_per_page, as: :number
      f.input :maintenance_mode, as: :select, collection: [['Off', false], ['On', true]], include_blank: false
      f.input :maintenance_message, as: :html_editor
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :website_name do |system_setting|
        system_setting.name
      end

      row :website_logo do |system_setting|
        image_tag system_setting.logo.url(:small)
      end

      row :email_sender
      row :listing_per_page
      row :maintenance_mode
      row :maintenance_message
      row :created_at
      row :updated_at
    end
  end

end
