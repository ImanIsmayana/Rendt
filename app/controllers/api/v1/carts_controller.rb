class Api::V1::CartsController < Api::V1::ApiController
  resource_description do
    api_versions "1.0"
  end

  skip_before_action :verify_authenticity_token
  before_action :check_user_authentication

  respond_to :json

  api :GET, "/v1/carts/all", "Get list of all product on user's cart"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User who will favourite a product", required: true
  # param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all items or products on user's cart"

  # OPTIMIZE let's add includes(:product) to avoid N+1 query and specify fields needed (done)
  def all
    @carts = Cart.get_all_of_carts(@user, params[:page])
    if @carts.present?
      @carts
    else
       @object = 'Cart'
      render "api/v1/errors/404", status: 401
    end
  end

  api :POST, "/v1/carts/add_item", "User has ability to add item or product to his cart"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User who will add product to cart", required: true
  param :product_id, String, desc: "Product ID or Junkyard ID Lender wants to take to cart", required: true
  param :cart_type, String, desc: "Type of cart for distinguish of product with junkyard ('product' or 'junkyard')", required: true
  description "User has ability to add item or product to his cart before checkout process"

  # OPTIMIZE could we use find_by_id! ? so once data not found it will raise 404 error from Rails, it will make no repeating 404 error handler
  def add_item
    item =
      if params[:cart_type].eql? 'product'
        Product.find_by(id: params[:product_id])
      elsif params[:cart_type].eql? 'junkyard'
        JunkyardProduct.find_by(id: params[:product_id])
      end

    if item
      @user.carts.where(product_id: item, aasm_state: params[:cart_type]).first_or_create
    else
      @object = 'Product or Junkyard'
      render "api/v1/errors/404", status: 401
    end
  end

  api :POST, "/v1/carts/remove_item", "User has ability to remove item or product from his cart"
  formats ['json']
  param :product_id, String, desc: "Product ID Lender wants to remove from cart", required: true
  param :authentication_token, String, desc: "Authentication token of User who will remove product to cart", required: true
  description "User has ability to remove item or product from his cart"

  def remove_item
    product = Product.find_by_id(params[:product_id])

    if product
      @user.carts.where(product_id: product).destroy_all
    else
      @object = "Product"
      render "api/v1/errors/404", status: 404
    end
  end
end
