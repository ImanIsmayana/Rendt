ActiveAdmin.register User do
  #
  # get user
  #
  before_action :set_user, only: [:block, :unblock, :edit]

  #
  # setting up strong parameters
  #
  permit_params :email, :first_name, :last_name, :address, :latitude, :longitude, 
    :phone_number, attachment_attributes: [:id, :name]

  #
  # setting actions available
  #
  actions :all, except: [:new]

  #
  # setting filter action
  #
  filter :email
  filter :first_name
  filter :last_name
  filter :address
  filter :created_at

  #
  # setting data sort
  #
  config.sort_order = 'id_asc'

  #
  # scoping for status transfer request
  #
  scope :active_account, default: true do |user|
    user.where(is_blocked: :false)
  end

  scope :blocked_account do |user|
    user.where(is_blocked: :true)
  end

  scope :all

  #
  # index page configuration
  #
  index do
    selectable_column
    column :id

    column :image do |user|
      if user.attachment
        image_tag user.attachment.name.thumb.url, class: 'current-user-image', alt: user.full_name 
      else
        image_tag '/images/fallback/noimg96x96.jpg', class: 'current-user-image', alt: user.full_name 
      end
    end

    column :name do |user|
      user.full_name
    end

    column :address
    column :phone_number
    column :created_at
    
    actions default: true, name: 'Actions' do |user|
      if user.is_blocked
        link_to 'Unblock', unblock_admin_users_path(user), method: :post
      else
        link_to 'Block', block_admin_users_path(user), method: :post
      end
    end
  end

  #
  # show page configuration
  #
  show do
    attributes_table do
      row :id

      row :image do |user|
        image_tag user.attachment.name.thumb.url, alt: user.full_name if user.attachment
      end

      row :name do |user|
        user.full_name
      end

      row :address
      row :phone_number
      row :created_at
      row :updated_at
    end
  end

  #
  # create or edit form configuration
  #
  form do |f|
    f.inputs "User" do
      f.input :email, input_html: { disabled: !f.object.new_record? }
      f.input :first_name
      f.input :last_name
      f.input :address
      f.input :latitude
      f.input :longitude
      f.input :phone_number
      f.fields_for :attachment, (f.object.attachment || f.object.build_attachment) do |attachment|
        attachment.input :name, label: 'Image', hint: f.object.attachment_uploader_hint.html_safe
      end
    end

    f.actions
  end

  #
  # controller configuration
  #
  controller do
    #
    # use eager loading associated
    #
    def scoped_collection
      super.includes :attachment
    end

    def block
      if @user.update_attributes(is_blocked: true)
        redirect_to admin_users_url, notice: "#{@user.full_name} already blocked"
      else
        redirect_to admin_users_url, alert: 'Something went wrong when try to block user'
      end
    end

    def unblock
      if @user.update_attributes(is_blocked: false)
        redirect_to admin_users_url, notice: "#{@user.full_name} already unblocked"
      else
        redirect_to admin_users_url, alert: 'Something went wrong when try to block user'
      end
    end

    private
      def set_user
        @user = User.find_by(id: params[:user_id] || params[:id])
      end
  end
end
