ActiveAdmin.register Checkout do
  #
  # setting actions available
  #
  actions :all, except: [:new, :edit, :destroy]

  #
  # setting filter action
  #
  filter :user
  filter :transaction_id
  filter :payment_type

  #
  # setting data sort
  #
  config.sort_order = 'id_asc'

  #
  # scoping for product or junkyard
  #
  scope :products, default: true do |checkout|
    checkout.paid
  end

  scope :junkyard_products do |checkout|
    checkout.junkyard
  end

  #
  # index page configuration
  #
  index do
    selectable_column
    column :id
    column :renter do |checkout|
      link_to checkout.user.full_name, admin_user_path(checkout.user)
    end

    column :transaction_id do |checkout|
      if checkout.checkout_type.eql? 'junkyard'
        'No Transaction ID'
      else
        checkout.transaction_id
      end
    end

    column :pay_key do |checkout|
      if checkout.checkout_type.eql? 'junkyard'
        'No Pay Key'
      else
        checkout.pay_key
      end
    end

    column :total_paid do |checkout|
      if checkout.checkout_type.eql? 'junkyard'
        'No Total Paid'
      else
        number_to_currency checkout.total_paid
      end
    end

    column :pay_status

    column :transaction_date do |checkout_item|
      checkout_item.updated_at.strftime("%B %d, %Y %H:%M:%S")
    end

    actions
  end

  #
  # show page configuration
  #
  show do
    attributes_table do
      row :id
      row :user
      row :transaction_id
      row :pay_key
      row :pay_status
      row :created_at

      panel "Items" do
        if checkout.checkout_type.eql? 'junkyard'
          table_for checkout.checkout_items do
            column :product

            column :lender do |checkout_item|
              link_to checkout_item.product.user.full_name, admin_user_path(checkout_item.product.user)
            end
          end
        else
          table_for checkout.checkout_items do
            column :product

            column :lender do |checkout_item|
              link_to checkout_item.product.user.full_name, admin_user_path(checkout_item.product.user)
            end

            column :rent_time do |checkout_item|
              checkout_item.rent_time.gsub('_', ' ') rescue '-'
            end

            column :price do |checkout_item|
              number_to_currency checkout_item.price
            end

            column :deposit do |checkout_item|
              number_to_currency checkout_item.deposit
            end

            column :total_price do |checkout_item|
              number_to_currency checkout_item.total_price
            end

            column :start_time
            column :end_time
          end
        end
      end
    end
  end

  #
  # controller configuration
  #
  controller do
    #
    # use eager loading associated
    #
    def scoped_collection
      super.includes :checkout_items => [:product => [:user]]
    end
  end
end
