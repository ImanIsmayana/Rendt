ActiveAdmin.register TransferRequest do
  #
  # setting up strong parameters
  #
  # permit_params :list, :of, :attributes, :on, :model

  #
  # setting actions available
  #
  actions :all, except: [:new, :edit, :destroy, :show]

  #
  # setting filter action
  #
  filter :user
  filter :created_at

  #
  # setting data sort
  #
  config.sort_order = 'id_desc'

  #
  # scoping for status transfer request
  #
  scope :pending_requests, default: true do |requests|
    requests.where(aasm_state: :pending)
  end

  scope :approved_requests, default: true do |requests|
    requests.where(aasm_state: :approved)
  end

  scope :all

  #
  # index page configuration
  #
  index do
    selectable_column

    column :name do |tranfer_request|
      tranfer_request.user.full_name.titleize
    end

    column :requested_amount do |tranfer_request|
      number_to_currency tranfer_request.requested_amount
    end

    column :requested_at do |transfer_request|
      transfer_request.created_at
    end

    column :action do |transfer_request|
      if transfer_request.approved?
        'Approved'
      else
        link_to 'Approve', admin_transfer_request_path(transfer_request), method: :put
      end
    end
  end

  #
  # controller configuration
  #
  controller do
    include ActionView::Helpers::NumberHelper

    #
    # use eager loading associated
    #
    def scoped_collection
      super.includes :user
    end

    def update
      transfer_request = TransferRequest.find_by(id: params[:id])
      lender = transfer_request.user

      if lender.update(balance: lender.balance - transfer_request.requested_amount)
        transfer_request.update(aasm_state: :approved)

        activity = PublicActivity::Activity.new

        body_message = "Your request with amount #{number_to_currency(transfer_request.requested_amount)}
          on #{transfer_request.created_at.strftime("%B %d, %Y %H:%M:%S")} already approved by Admin"

        #
        # create activity includes send notification to mobile
        #
        @response = activity.create_notification(
          key: 'transfer_request.approved',
          owner: current_admin_user,
          recipient: lender,
          notification_type: 'approved',
          title_message: "Approved Request",
          body_message: body_message
        )

        redirect_to admin_transfer_requests_url, notice: 'Successfully approved transfer request'

      else
        redirect_to admin_transfer_requests_url, alert: 'Something went wrong when try to approve the transfer request'
      end
    end
  end
end
