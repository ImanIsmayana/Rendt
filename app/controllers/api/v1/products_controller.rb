class Api::V1::ProductsController < Api::V1::ApiController
  resource_description do
    api_versions "1.0"
  end

  skip_before_action :verify_authenticity_token

  before_action :check_user_authentication
  before_action :get_message, only: :reply_enquiry
  before_action :set_product, only: [:update, :delete, :upload_photo, :set_status, :set_rent_status]
  before_action :set_category, only: [:by_category, :by_favourite] #, :by_price]

  respond_to :json

  api :GET, "/v1/products/all", "Get list of all products"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User"
  param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all items or products"

  # OPTIMIZE let's includes(:attachments, :category) to avoid N+1 query (done)
  def all
    @products = Product.get_list_active_products.page(params[:page]).per(10)
  end

  api :GET, "/v1/products/by_category", "Get list of all products filter by category"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User"
  param :category_id, String, desc: "Category ID of Item or Product", required: true
  param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all items or products filter by category"

  def by_category
    @products = @category.products.active.page(params[:page]).per(10)
  end

  api :GET, "/v1/products/by_user", "Get list of all products filter by user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :user_id, String, desc: "User ID of products owner"
  param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all items or products filter by category"

  def by_user
    @user = User.find_by(id: params[:user_id]) if params[:user_id].present?

    if @user
      @products = @user.products.get_list_active_products.page(params[:page]).per(10)
      render json: {status: 200}
    else
      @object = "User"
      render "api/v1/errors/404", status: 404
    end
  end

  api :GET, "/v1/products/by_favourite", "Get list of all products filter by favourite"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :category_id, String, desc: "Category ID of Item or Product", required: true
  param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all items or products filter by favourite"

  def by_favourite
    @products = @category.products.includes(:attachments).active
      .order(favourites_count: :desc).page(params[:page]).per(10)
    render json: {status: 200}
  end

  api :GET, "/v1/products/by_price", "Get list of all products filter by price"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :category_id, String, desc: "Category ID of Item or Product", required: true
  param :rent_time, String, desc: "
    Filter item based on rent time ('1h', '4h', '1d', and '1w'), from lowest price to highest price
    [Important : Default sort by lowest price]", required: true
  param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all items or products filter by price based on rent time from lowest price to highest price"

  def by_price
    @products = Product.get_by_price(params[:category_id], params[:rent_time])
    render json: {status: 200}
  end

  api :GET, "/v1/products/detail", "Get detail of the product"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User"
  param :product_id, String, desc: "Product ID", required: true
  description "Get detail items or products"

  def detail
    @product = Product.find_by(id: params[:product_id])

    if @product.blank?
      @object = "Product"
      render "api/v1/errors/404", status: 404
    end
  end

  api :POST, "/v1/products/create", "Post a new item or product"
  formats ['json']
  param :name, String, desc: "Item or Product Name - Length 3..100 characters", required: true
  param :one_hour, String, desc: "Rent price of the Item or Product per one hour", required: true
  param :four_hours, String, desc: "Rent price of the Item or Product per four hours", required: true
  param :one_day, String, desc: "Rent price of the Item or Product per one day", required: true
  param :one_week, String, desc: "Rent price of the Item or Product per one week", required: true
  param :description, String, desc: "Detail of the Item or Product to be advertised", required: true
  param :location, String, desc: "User Address / Desired meet up location", required: true
  param :latitude, String, desc: "User Latitude", required: true
  param :longitude, String, desc: "User Longitude", required: true
  param :size, String, desc: "Detail size info about the Item or Product"
  param :special_condition, String, desc: "Special condition about the Item or Product to be advertised."
  param :deposit, String, desc: "Give it value '0' if the Item or Product don't need any deposit before rent"
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :category_id, String, desc: "Category ID of Item or Product", required: true
  description "Post a new item or product to public to get renter interest"

  # OPTIMIZE let's use strong parameter to make it shorter (done)
  def create
    product = Product.new(product_params)

    if product.save
      @product = product
      render json: {status: 201}
    else
      @error = 1
      @errors = product.errors
      render json: {status: 422}
    end
  end

  api :POST, "/v1/products/update", "Update item or product"
  formats ['json']
  param :id, String, desc: "ID of Product", required: true
  param :name, String, desc: "Item or Product Name - Length 3..100 characters", required: true
  param :one_hour, String, desc: "Rent price of the Item or Product per one hour", required: true
  param :four_hours, String, desc: "Rent price of the Item or Product per four hours", required: true
  param :one_day, String, desc: "Rent price of the Item or Product per one day", required: true
  param :one_week, String, desc: "Rent price of the Item or Product per one week", required: true
  param :description, String, desc: "Detail of the Item or Product to be advertised", required: true
  param :location, String, desc: "User Address / Desired meet up location", required: true
  param :latitude, String, desc: "User Latitude", required: true
  param :longitude, String, desc: "User Longitude", required: true
  param :size, String, desc: "Detail size info about the Item or Product"
  param :special_condition, String, desc: "Special condition about the Item or Product to be advertised."
  param :deposit, String, desc: "Give it value '0' if the Item or Product don't need any deposit before rent"
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :category_id, String, desc: "Category ID of Item or Product", required: true
  description "Update item or product to public"

  def update
    if @current_product.update(product_params)
      @product = @current_product
      render json: {status: 200}
    else
      @error = 1
      @errors = product.errors
      render json: {status: 304}
    end
  end

  api :GET, "/v1/products/delete", "Delete product"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User"
  param :product_id, String, desc: "Product ID", required: true
  description "Delete product by product owner"

  # OPTIMIZE we can search product from @user.products so it will be shorter (done)
  def delete
    @current_product.delete

    if @current_product.save
      @product = @current_product
      render json: {status: 200}
    else
      @object = "Product"
      render "api/v1/errors/404", status: 404
    end
  end

  api :POST, "/v1/products/upload_photo", "Upload photo for item or product"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :product_id, String, desc: "Product ID of photo to be uploaded", required: true
  description "Upload photo for item or product. Each product has ability to have 8 photos. [Important : Add parameter called 'name' for file upload]"

  # OPTIMIZE it will be great if we can add limit validation on attachment model for product
  def upload_photo
    if @current_product
      product_photos = @current_product.attachments.count

      if product_photos <= 8
        photo = @current_product.attachments.new(name: params[:name])

        if photo.save
          @photo = photo
          render json: {status: 201}
        else
          @error = 1
          @errors = photo.errors
          render json: {status: 422}
        end
      else
        @error = 1
        @errors = {photo: ["Product already has maximum number of photos! (8 photos)"]}
      end
    else
      @object = "Product"
      render "api/v1/errors/404", status: 404
    end
  end

  api :POST, "/v1/products/set_status", "Lender set status of the product or item"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :product_id, String, desc: "Product ID Lender wants to change its status", required: true
  param :status, String, desc: "Status of the product or item ('available', 'not_available', or 'not_yet_returned')", required: true
  description "
    Lender could set product status to be available if product is available and set to not available if product is not available
    and set product to be not_yet_returned if product is not yet returned"

  # OPTIMIZE we need to looking for safest way to toggle product status without using raw value of params[:status],
  # maybe we can create private method and validate params[:status] value before execute it (done)
  def set_status
    @current_product.aasm_state = params[:status]

    if @current_product.save
      @product_status = @current_product.aasm_state
      render json: {status: 200}
    else
      @object = "Product"
      render "api/v1/errors/404", status: 404
    end
  end

  api :POST, "/v1/products/set_rent_status", "Lender set status of the product or item will be take"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :product_id, String, desc: "Product ID Lender wants to change its status", required: true
  param :status, String, desc: "Status of the product or item ('taken', 'rent', 'need_refunded', 'refunded', or 'not_rent')", required: true
  description "
    lender could set item status to be taken if item already taken by renter,
    set to be rent if the item has not been taken but the renter already pay rent item,
    set to be need_refunded if the item already returned but the item not yet need_refunded,
    set to be refunded if the item already returned,
    and lender can set item status to be not rent if the item no one has hired or the item already returned by renter."

  def set_rent_status
    if @current_product.update(rent_status: product_params[:status])
      @rent_status = @current_product.rent_status
      render json: {status: 200}
    else
      @error = 1
      @errors = @current_product.errors
      render json: {status: 422}
    end
  end

  api :POST, "/v1/products/like", "User has ability to like item or product"
  formats ['json']
  param :product_id, String, desc: "Product ID to like", required: true
  param :authentication_token, String, desc: "Authentication token of User who will like a product", required: true
  description "Ability for user to likes a product"

  def like
    product = Product.find_by(id: params[:product_id])

    if product
      if @user.mobile_platform
        vote = @user.votes.find_by(votable_id: product.id, votable_type: 'Product', voter_id: @user.id)

        unless vote
          @user.likes product

          activity = PublicActivity::Activity.new
          title_message = "#{@user.full_name} liked you product #{product.name}"

          #
          # create activity includes send notification to mobile
          #
          @response = activity.create_notification(
            key: 'like.product',
            owner: @user,
            recipient: product.user,
            notification_type: 'like',
            title_message: title_message,
            another_parameters: {
              product_id: product.id,
              product_name: product.name
            },
            status: 201
          )
        end
      else
        @object = "Device ID from Mobile Platform"
      end
    else
      @object = "Product"
    end

    render "api/v1/errors/404", status: 404 if @object
  end

  api :POST, "/v1/products/unlike", "User has ability to unlike item or product"
  formats ['json']
  param :product_id, String, desc: "Product ID to unlike", required: true
  param :authentication_token, String, desc: "Authentication token of User who will unlike a product", required: true
  description "Ability for user to unlikes a product"

  def unlike
    product = Product.find_by(id: params[:product_id])

    if product
      if @user.mobile_platform
        @user.unlike product
        render json: {status: 200}
      else
        @object = "Device ID from Mobile Platform"
      end
    else
      @object = "Product"
    end

    render "api/v1/errors/404", status: 404 if @object
  end

  api :GET, "/v1/products/enquiries", "List of product enquiries"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  description "Ability for Lender to get list of enquiries based on his own items or products"

  # OPTIMIZE try to avoid N+1 query (done)
  def enquiries
    messages = CustomMessage.includes(:sent_messageable, :documentable).where(received_messageable: @user, ancestry:nil)

    if messages
      @message_parents = messages
      render json: {status: 200}
    else
      @object = "Message"
      render "api/v1/errors/404", status: 404
    end
  end

  api :GET, "/v1/products/enquiries_by_product", "List of product enquiries"
  formats ['json']
  param :product_id, String, desc: "Product ID of enquiries", required: true
  param :authentication_token, String, desc: "Authentication token of User", required: true
  description "Ability for Lender to get list of enquiries based on his own items or products"

  def enquiries_by_product
    # Hai ganteng -> Find by id is deprecated use find_by(id: params[:product_id]) or just use .find for ID (done)
    product = Product.find_by(id: params[:product_id])

    if product
      if !product.messages.empty?
        @product = product.messages.first.documentable
        @message_parents = product.messages.includes(:sent_messageable).where(ancestry: nil)
        render json: {status: 200}
      end
    else
      @object = "Product"
      render "api/v1/errors/404", status: 404
    end
  end

  api :GET, "/v1/products/enquiries/renter_conversation", "Conversation between Lender and Renter from Renter side"
  formats ['json']
  param :product_id, String, desc: "Product ID of enquiries", required: true
  param :authentication_token, String, desc: "Authentication token of User", required: true
  description "Get conversation between Lender and Renter from Renter side - Called after click enquiries button on product detail as Renter"

  def renter_conversation
    @product = Product.find_by(id: params[:product_id])

    if @product
      message = @product.messages.where(sent_messageable_id: @user.id, ancestry: nil).first

      if message
        @messages = message.conversation
        render json: {status: 200}
      end
    else
      @object = "Product"
      render "api/v1/errors/404", status: 404
    end
  end

  api :GET, "/v1/products/enquiries/lender_conversation", "Conversation between Lender and Renter from Lender side"
  formats ['json']
  param :product_id, String, desc: "Product ID of enquiries", required: true
  param :message_id, String, desc: "Message ID of enquiries", required: true
  param :authentication_token, String, desc: "Authentication token of User", required: true
  description "Get conversation between Lender and Renter from Lender side - Called after click enquiries button on product detail as Lender"

  def lender_conversation
    @product = Product.find_by(id: params[:product_id])

    if @product
      if @product.user == @user
        message = @product.messages.where(id: params[:message_id], received_messageable_id: @user.id, ancestry: nil).first

        if message
          @messages = message.conversation.includes(:sent_messageable, :received_messageable).order("id asc")
          render json: {status: 200}
        end
      else
        render "api/v1/errors/403", status: 403
      end
    else
      @object = "Product"
      render "api/v1/errors/404", status: 404
    end
  end

  api :POST, "/v1/products/post_enquiry", "Ability for user to post enquiry of an item or product"
  formats ['json']
  param :product_id, String, desc: "Product ID to post enquiry", required: true
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :message, String, desc: "Content of enquiries", required: true
  description "Ability for user to post enquiry of an item or product"

  def post_enquiry
    product = Product.includes(:user => :mobile_platform).find_by(id: params[:product_id])

    if product
      @message = @user.send_message(product.user, {
        body: params[:message], documentable_id: product.id, documentable_type: product.class.name
      })

      user_as_lender = product.user
      activity = PublicActivity::Activity.new
      body_message = params[:message]

      #
      # create activity includes send notification to mobile
      #
      activity.create_notification(
        key: 'post.enquery',
        owner: @user,
        recipient: user_as_lender,
        notification_type: 'post_message',
        body_message: body_message,
        another_parameters: {
          enquiry_id: @message.id,
          product_id: product.id,
          product_name: product.name
        },
        status: 200
      )
    else
      @object = "Product"
      render "api/v1/errors/404", status: 404
    end
  end

  api :POST, "/v1/products/reply_enquiry", "Ability for user to post enquiry of an item or product"
  formats ['json']
  param :product_id, String, desc: "Product ID to reply enquiry", required: true
  param :message_id, String, desc: "Message ID Lender to be replied", required: true
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :message, String, desc: "Content of enquiries", required: true
  description "Ability for user to reply enquiry of an item or product"

  def reply_enquiry
    product = Product.includes(:user => :mobile_platform).find_by(id: params[:product_id])

    if product
      @message = @user.reply_to(@message, {
        body: params[:message], documentable_id: product.id, documentable_type: product.class.name
      })

      user_as_lender = product.user
      activity = PublicActivity::Activity.new
      body_message = params[:message]

      #
      # create activity includes send notification to mobile
      #
      activity.create_notification(
        key: 'post.enquery',
        owner: @user,
        recipient: user_as_lender,
        notification_type: 'reply_message',
        body_message: body_message,
        another_parameters: {
          enquiry_id: @message.id,
          product_id: product.id,
          product_name: product.name
        },
        status: 200
      )
    else
      @object = "Product"
      render "api/v1/errors/404", locals: {object: "Product"}, status: 404
    end
  end

  private
    def get_message
      @message = CustomMessage.find_by(id: params[:message_id])

      if @message.blank?
        @object = "Message"
        render "api/v1/errors/404", status: 404
      end
    end

    def set_product
      @current_product = Product.find_by(id: params[:product_id] || params[:id])

      unless @current_product
        @object = "Product"
        render "api/v1/errors/404", status: 404
      end
    end

    def set_category
      if params[:category_id]
        @category = Category.find_by(id: params[:category_id])

        unless @category
          @object = "Category"
          render "api/v1/errors/404", status: 404
        end
      else
        render "api/v1/errors/401", status: 401
      end
    end

    def product_params
      product_params = params.except!(:authentication_token).permit(:product_id, :name, :one_hour, :four_hours, :one_day, :one_week,
        :description, :location, :latitude, :longitude, :size, :special_condition, :deposit, :category_id, :user_id,
        :rent_status, :status)
      product_params.merge(user_id: @user.id)
    end
end
