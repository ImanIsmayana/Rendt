class Api::V1::CategoriesController < Api::V1::ApiController
  resource_description do
    api_versions "1.0"
  end

  skip_before_action :verify_authenticity_token
  before_action :check_user_authentication, only: :create

  respond_to :json

  api :GET, "/v1/categories/all", "Get list of all categories"
  formats ['json']
  description "Get list of all item or product categories."
  # param :page, String, desc: "Page number of listing - per 10 data", required: true
  # OPTIMIZE let's add includes(:attachment) to avoid N+1 query and specify fields needed (done)
  def all
    @categories = Category.includes(:attachments, :products, :junkyard_products).select(:id, :name, :image)
    if @categories.present?
      @categories
      @product_count = @categories.count('products.*')
      @junkyard_count = @categories.count('junkyard_products.*')
    else
      @object = 'Category'
      render "api/v1/errors/404", status: 401
    end
  end

  api :POST, "/v1/categories/create", "Create a new category product"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User"
  param :name, String, desc: "Category product name - Length 3..100 characters", required: true
  description "Create a new category item or product"

  # OPTIMIZE let's use strong parameter and nested attributes for saving category along with its attachments
  def create
    category = Category.new(
      name: params[:name]
    )

    if category.save
      attachment = category.attachments.create(name: params[:image]) if params[:image]
      @category = category
    else
      @error = 1
      @errors = category.errors
    end
  end
end
