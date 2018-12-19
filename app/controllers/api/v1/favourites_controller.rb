class Api::V1::FavouritesController < Api::V1::ApiController
  resource_description do
    api_versions "1.0"
  end

  skip_before_action :verify_authenticity_token
  before_action :check_user_authentication
  before_action :set_user_as_lender, only: [:create_lender, :destroy_favourite_lender]
  before_action :set_junkyard, only: [:create_junkyard, :destroy_favourite_junkyard]

  respond_to :json

  api :GET, "/v1/favourites/all", "Get list of all items or products favourites of a user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User who will favourite a product", required: true
  param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all items or products favourites from a user"

  # OPTIMIZE let's add includes(:favouritable) to avoid N+1 query
  def all
    @favourites = Favourite.get_all(@user.id, 'Product').page(params[:page]).per(10)
  end

  api :GET, "/v1/favourites/all_lender", "Get list of all favourites lender of a user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User who will favourite a product", required: true
  param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all favourites lender from a user"

  def all_lender
    @favourites = Favourite.get_all(@user.id, 'User').page(params[:page]).per(10)
  end

  api :POST, "/v1/favourites/create", "User has ability to add item or product to be his favourites"
  formats ['json']
  param :product_id, String, desc: "Product ID Lender wants to make it as favourite", required: true
  param :authentication_token, String, desc: "Authentication token of User who will favourite a product", required: true
  description "Ability for user to favourite a product"

  def create
    product = Product.includes(:user => :mobile_platform).find_by(id: params[:product_id])

    if product
      user_favourites = Favourite.get_favourites_or_create(@user.id, product.id, 'Product')

      if user_favourites
        activity = PublicActivity::Activity.new
        body_message = "Your product already favorited by #{@user.full_name}"

        #
        # create activity includes send notification to mobile
        #
        response_notif = activity.create_notification(
          key: 'favourite.product',
          owner: @user,
          recipient: product.user,
          notification_type: 'favourite_product',
          title_message: 'Favorite Product',
          body_message: body_message,
          another_parameters: {
            product_id: product.id,
            product_name: product.name
          },
          status: 201
        )
        if response_notif[:error]
          @object = response_notif[:object]
          render "api/v1/errors/404", status: 404
        end
      end
    else
      is_exists?(product, 'product')
    end
  end

  api :POST, "/v1/favourites/create_lender", "User has ability to add lenders to be his favourites"
  formats ['json']
  param :user_id, String, desc: "User ID Lender wants to make it as favourite", required: true
  param :authentication_token, String, desc: "Authentication token of User who will favourite a lender", required: true
  description "Ability for user to favourite a lender"

  def create_lender
    user_favourites = Favourite.get_favourites_or_create(@user.id, @user_as_lender.id, 'User')

    if user_favourites
      activity = PublicActivity::Activity.new
      body_message = "You have already favorited by #{@user.full_name}"

      #
      # create activity includes send notification to mobile
      #
      response_notif = activity.create_notification(
        key: 'favourite.lender',
        owner: @user,
        recipient: @user_as_lender,
        notification_type: 'favourite_lender',
        title_message: 'Favorit Lender',
        body_message: body_message,
        another_parameters: {
          owner_name: @user.full_name
        },
        status: 201
      )

      if response_notif[:error]
        @object = response_notif[:object]
        render "api/v1/errors/404", status: 404
      end
    end
  end

  api :POST, "/v1/favourites/create_junkyard", "User has ability to add item or junkyard product to be his favourites"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User who will favourite a junkyard product", required: true
  param :junkyard_product_id, String, desc: "Junkyard product ID Lender wants to make it as favourite", required: true
  description "Ability for user to favourite a junkyard product"

  def create_junkyard
    user_favourites = Favourite.get_favourites_or_create(@user.id, @junkyard.id, 'JunkyardProduct')

    if user_favourites
      activity = PublicActivity::Activity.new
      body_message = "Your product already favorited by #{@user.full_name}"

      #
      # create activity includes send notification to mobile
      #
      response_notif = activity.create_notification(
        key: 'favourite.junkyard_product',
        owner: @user,
        recipient: @junkyard.user,
        notification_type: 'favourite_junkyard_product',
        title_message: 'Favorite Product',
        body_message: body_message,
        another_parameters: {
          product_id: @junkyard.id,
          product_name: @junkyard.name
        },
        status: 201
      )

      if response_notif[:error]
        @object = response_notif[:object]
        render "api/v1/errors/404", status: 404
      end
    end
  end

  api :POST, "/v1/favourites/destroy", "User has ability to remove item or product from his favourites"
  formats ['json']
  param :product_id, String, desc: "Product ID Lender wants to remove it from favourite", required: true
  param :authentication_token, String, desc: "Authentication token of User who will remove favourite from a product", required: true
  description "Ability for user to remove favourite from a product"

  def destroy
    product = Product.find_by(id: params[:product_id])

    if product
      favourite = Favourite.get_favourites(@user.id, product.id, 'Product').first

      if favourite.present?
        favourite.destroy
      else
        is_exists?(favourite, 'favourite product')
      end
    else
      is_exists?(product, 'product')
    end
  end

  api :POST, "/v1/favourites/destroy_favourit_lender", "User has ability to unfavourite lender"
  formats ['json']
  param :user_id, String, desc: "User ID Lender wants to make it as unfavourite", required: true
  param :authentication_token, String, desc: "Authentication token of User who will remove favourite from a product", required: true
  description "Ability for user to remove favourite from a product"

  def destroy_favourite_lender
    user_favourite = Favourite.get_favourites(@user.id, @user_as_lender.id, 'User').first

    if user_favourite.present?
      user_favourite.destroy
    else
      is_exists?(user_favourite, 'Favourite')
    end
  end

  api :POST, "/v1/favourites/destroy_favourite_junkyard", "User has ability to unfavourite junkyard"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User who will remove favourite from a product", required: true
  param :junkyard_product_id, String, desc: "Junkyard product ID Lender wants to make it as favourite", required: true
  description "Ability for user to remove favourite from a junkyard product"

  def destroy_favourite_junkyard
    user_favourite = Favourite.get_favourites(@user.id, @junkyard.id, 'JunkyardProduct').first

    if user_favourite.present?
      user_favourite.destroy
    else
      is_exists?(user_favourite, 'Favourite Junkyard Product')
    end
  end

  private
    def set_user_as_lender
      @user_as_lender = User.includes(:products).find_by(id: params[:user_id])

      if @user_as_lender.products.blank?
        is_exists?(@user_as_lender, 'Lender')
      end
    end

    def set_junkyard
      @junkyard = JunkyardProduct.find_by(id: params[:junkyard_product_id])

      unless @junkyard
        is_exists?(@junkyard, 'Junkyard Product')
      end
    end

    #
    # check if checkout or payment response is exists and set status to 404
    #
    def is_exists?(objects, object_value)
      unless objects
        @object = object_value.titleize
        render "api/v1/errors/404", status: 404
      end
    end
end
