class Api::V1::JunkyardProductsController < Api::V1::ApiController
  resource_description do
    api_versions "1.0"
  end

  skip_before_action :verify_authenticity_token
 
  before_action :check_user_authentication
  before_action :set_junkyard_product, only: [:detail, :update, :delete, :like, :unlike, :upload_photo]
  before_action :set_category, only: [:by_category, :by_favourite, :by_price]

  respond_to :json

  api :GET, "/v1/junkyard_products/all", "Get list of all virtual junk yards"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all item or product."

  def all
    @junk_yard_products = JunkyardProduct.get_list_active_junkyard_products.page(params[:page]).per(10)
  end

  api :GET, "/v1/junkyard_products/by_category", "Get list of all junkyard products filter by category"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User"
  param :category_id, String, desc: "Category ID of Item or Product", required: true
  param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all items or products in junkyard and filter by category"

  def by_category
    @junkyard_products = @category.junkyard_products.active.page(params[:page]).per(10)
  end

  api :GET, "/v1/junkyard_products/by_user", "Get list of all junkyard products filter by user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :user_id, String, desc: "User ID of products owner"
  param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all items or products in junkyard and filter by user"

  def by_user
    @user = User.find_by_id(params[:user_id]) if params[:user_id].present?

    if @user
      @junkyard_products = @user.junkyard_products.get_list_active_junkyard_products.page(params[:page]).per(10)
    else
      @object = "User"
      render "api/v1/errors/404", status: 404
    end
  end

  api :GET, "/v1/junkyard_products/by_favourite", "Get list of all junkyard products filter by favourite"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :category_id, String, desc: "Category ID of Item or Product", required: true
  param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all items or junkyard products filter by favourite"

  def by_favourite
    @junkyard_products = @category.junkyard_products.includes(:attachments).active
      .order(favourites_count: :desc).page(params[:page]).per(10)
  end

  api :GET, "/v1/junkyard_products/detail", "Get detail of the junkyard product"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User"
  param :junkyard_product_id, String, desc: "Junkyard product ID", required: true
  description "Get detail items or junkyard products"

  def detail
    @junkyard_product = @junkyard
  end

  api :POST, "/v1/junkyard_products/like", "User has ability to like item or junkyard product"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User who will like a product", required: true
  param :junkyard_product_id, String, desc: "Junkyard product ID to like", required: true
  description "Ability for user to likes a junkyard product"

  def like
    if @user.mobile_platform
      vote = @user.votes.find_by(votable_id: @junkyard.id, votable_type: 'JunkyardProduct', voter_id: @user.id)

      unless vote
        @user.likes @junkyard

        activity = PublicActivity::Activity.new
        title_message = "#{@user.full_name} liked you product #{@junkyard.name}"

        #
        # create activity includes send notification to mobile
        #
        @response = activity.create_notification(
          key: 'like.junkyard_product',
          owner: @user,
          recipient: @junkyard.user,
          notification_type: 'like',
          title_message: title_message
        )
      end
    else
      @object = "Device ID from Mobile Platform"
      render "api/v1/errors/404", status: 404
    end
  end

  api :POST, "/v1/junkyard_products/unlike", "User has ability to unlike item or junkyard product"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User who will unlike a product", required: true
  param :junkyard_product_id, String, desc: "Junkyard product ID to unlike", required: true
  description "Ability for user to unlikes a junkyard product"

  def unlike
    if @user.mobile_platform
      @user.unlike @junkyard
    else
      @object = "Device ID from Mobile Platform"
      render "api/v1/errors/404", status: 404
    end
  end

  api :POST, "/v1/junkyard_products/upload_photo", "Upload photo for item or junkyard product"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :junkyard_product_id, String, desc: "Junkyard product ID of photo to be uploaded", required: true
  description "Upload photo for item or junkyard product. Each junkyard product has ability to have 8 photos. 
    [Important : Add parameter called 'name' for file upload]"

  # OPTIMIZE it will be great if we can add limit validation on attachment model for product
  def upload_photo
    junkyard_photos = @junkyard.attachments.size

    if junkyard_photos <= 8
      @photo = @junkyard.attachments.new(name: params[:name])

      unless @photo.save
        @error = 1
        @errors = photo.errors
      end
    else
      @error = 1
      @errors = { photo: ["Junkyard product already has maximum number of photos! (8 photos)"] }
    end
  end

  api :POST, "/v1/junkyard_products/create", "Crate a new product to virtual junkyard"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User"
  param :name, String, desc: "Item or Product Name - Length 3..100 characters", required: true
  param :description, String, desc: "Detail of the Item or Product to be advertised", required: true
  param :special_condition, String, desc: "Special condition about the Item or Product to be advertised."
  param :location, String, desc: "User Address / Desired meet up location", required: true
  param :latitude, String, desc: "User Latitude", required: true
  param :longitude, String, desc: "User Longitude", required: true
  param :size, String, desc: "Detail size info about the Item or Product"
  param :category_id, String, desc: "Category ID of Item or Product", required: true
  description "Create a new item or product to virtual junkyard"

  def create
    junkyard_product = JunkyardProduct.includes(:category).new(junkyard_product_params)

    if junkyard_product.save
      @junkyard_product = junkyard_product
    else
      @error = 1
      @errors = junkyard_product.errors
    end
  end

  api :POST, "/v1/junkyard_products/update", "Update item or junkyard product"
  formats ['json']
  param :id, String, desc: "ID of Junkyard Product", required: true
  param :name, String, desc: "Item or Product Name - Length 3..100 characters", required: true
  param :description, String, desc: "Detail of the Item or Product to be advertised", required: true
  param :special_condition, String, desc: "Special condition about the Item or Product to be advertised."
  param :location, String, desc: "User Address / Desired meet up location", required: true
  param :latitude, String, desc: "User Latitude", required: true
  param :longitude, String, desc: "User Longitude", required: true
  param :size, String, desc: "Detail size info about the Item or Product"
  param :category_id, String, desc: "Category ID of Item or Product", required: true
  description "Update item or junkyard product to public"

  def update
    if @junkyard.update(junkyard_product_params)
      @junkyard_product =  @junkyard
    else
      @error = 1
      @errors = @junkyard.errors
    end
  end

  api :GET, "/v1/junkyard_products/delete", "Delete junkyard product"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User"
  param :id, String, desc: "ID of Junkyard Product", required: true
  description "Delete product by product owner"

  def delete
    if @junkyard.user_id.eql? @user.id
      @junkyard.delete
      @junkyard.save
      @junkyard_product = @junkyard
    else
      @object = 'Junkyard Product'
      render "api/v1/errors/403", status: 403
    end
  end

  private
    def set_junkyard_product
      @junkyard = JunkyardProduct.active.find_by(id: params[:id] || params[:junkyard_product_id])

      unless @junkyard
        @object = "Junkyard Product"
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

    def junkyard_product_params
      junk_product_params = params.except!(:authentication_token).permit(:id, :name, :description, :location, :latitude, :longitude, 
        :size, :special_condition, :category_id, :user_id, { name: []})
      junk_product_params.merge(user_id: @user.id)
    end
end