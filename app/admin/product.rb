ActiveAdmin.register Product do
  #
  # setting up strong parameters
  #
  permit_params :name, :one_hour, :four_hours, :one_day, :one_week, :description,
    :special_condition, :deposit, :size, :user_id, :category_id, :location, :latitude, :longitude,
    :aasm_state, attachments_attributes: [:id, :name]

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
  config.sort_order = 'id_desc'

  #
  # index page configuration
  #
  index do
    selectable_column
    column :name

    column :price_per_one_hour do |product|
      number_to_currency product.one_hour
    end

    column :price_per_four_hours do |product|
      number_to_currency product.four_hours
    end

    column :price_per_one_day do |product|
      number_to_currency product.one_day
    end

    column :price_per_one_week do |product|
      number_to_currency product.one_week
    end

    column :location

    column :deposit do |product|
      number_to_currency product.deposit
    end

    column :created_at
    actions defaults: true
  end

  #
  # show page configuration
  #
  show do
    attributes_table do
      row :id
      row :name
      row :category

      row :owner do |product|
        product.user.full_name
      end

      row :special_condition
      row :location
      row :latitude
      row :longitude
      row :description

      row :one_hour do |product|
        number_to_currency product.one_hour
      end

      row :four_hours do |product|
        number_to_currency product.four_hours
      end

      row :price_per_one_day do |product|
        number_to_currency product.one_day
      end

      row :price_per_one_week do |product|
        number_to_currency product.one_week
      end

      row :deposit do |product|
        number_to_currency product.deposit
      end

      row :favourites_count

      row :availability do |product|
        product.aasm_state
      end

      row :created_at
      row :updated_at

      row :image do |product|
        if product.attachments.present?
          product.attachments.map do |attachment|
            image_tag attachment.name.thumb.url, alt: product.name if attachment
          end.join("<br />").html_safe
        else
          image_tag '/images/fallback/noimg96x96.jpg', alt: product.name
        end
      end
    end
  end

  #
  # create or edit form configuration
  #
  form do |f|
    f.inputs "Product" do
      f.input :name
      f.input :category, prompt: "- Select a Category -"
      f.input :user, prompt: "- Select a User -"
      f.input :size
      f.input :location
      f.input :latitude
      f.input :longitude
      f.input :description
      f.input :special_condition
      f.input :one_hour
      f.input :four_hours
      f.input :one_day
      f.input :one_week
      f.input :deposit
      f.input :aasm_state, label: "Availability", as: :select, collection: [
        "available", "not_available", "not_yet_returned", "returned", "deleted"
      ]
    end

    f.has_many :attachments do |attachment|
      attachment.input :name,  as: :file, label: "Image"
    end

    f.actions
  end
end
