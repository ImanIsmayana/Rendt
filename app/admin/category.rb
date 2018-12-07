ActiveAdmin.register Category do
  #
  # setting up strong parameters
  #
  permit_params :name, :image

  #
  # setting actions available
  #
  actions :all

  #
  # setting filter action
  #
  filter :name

  #
  # setting data sort
  #
  config.sort_order = 'id_asc'

  #
  # index page configuration
  #
  index do
    selectable_column

    column :image do |category|
      if category.image
        image_tag category.image.thumb.url, alt: category.name
      else
       image_tag category.image.url, alt: category.full_name
      end
    end

    column :name
    column :created_at
    actions
  end

  #
  # show page configuration
  #
  show do
    attributes_table do
      row :id
      row :name
      row :created_at
      row :updated_at

      row :image do |category|
        image_tag category.image.small.url, alt: category.name
      end
    end
  end

  #
  # create or edit form configuration
  #
  form do |f|
    f.inputs "Category" do
      f.input :name

      f.input :image, as: :file, :hint => image_tag(f.object.image.thumb.url)
    end
    f.actions
  end
end
