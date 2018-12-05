ActiveAdmin.register GoogleAdsLocation do
  menu parent: 'Website Config'

  permit_params :name, :width, :location, :number, :status, :sort_order

  filter :name, as: :string
  filter :width
  filter :location
  filter :number
  filter :status
  filter :sort_order

  form do |f|
    f.inputs "Google Ads Location" do
      f.input :name
      f.input :width, as: :number
      f.input :location
      f.input :number, as: :number
      f.input :status
      f.input :sort_order, as: :number
    end

    f.actions
  end
end
