Rails.application.routes.draw do
  get 'pages/show'

  namespace :api do
  namespace :v1 do
    get 'lenders_controller/all'
    end
  end

  root 'home#index'

  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users, :controllers => { 
    registrations: 'users/registrations', 
    confirmations: 'users/confirmations'
  }

  post "admin/users/:user_id/block" => "admin/users#block", as: "block_admin_users"
  post "admin/users/:user_id/unblock" => "admin/users#unblock", as: "unblock_admin_users"

  apipie
  namespace :api do
    namespace :v1 do
      #
      # api routes related to user
      get "users/confirmed"
      get "users/profile"
      post "users/register"
      post "users/login"
      post "users/logout"
      post "users/forgot_password"
      post "users/resend_confirmation"
      post "users/hide_address"
      post "users/update"
      post "users/update_password"
      post "users/upload_photo"
      post "users/delete_photo"

      #
      # api routes related to category
      get "categories/all"
      post "categories/create"

      #
      # api routes related to product
      get "products/all"
      get "products/by_category"
      get "products/by_user"
      get "products/by_favourite"
      get "products/by_price"
      get "products/detail"
      post "products/create"
      post "products/update"
      post "products/delete"
      post "products/upload_photo"
      post "products/set_status"
      post "products/set_rent_status"
      post "products/like"
      post "products/unlike"
      get "products/enquiries"
      get "products/enquiries_by_product"
      get "products/enquiries/renter_conversation", to: "products#renter_conversation"
      get "products/enquiries/lender_conversation", to: "products#lender_conversation"
      post "products/post_enquiry"
      post "products/reply_enquiry"

      #
      # api routes related to favourite
      get "favourites/all"
      get "favourites/all_lender"
      post "favourites/create"
      post "favourites/create_lender"
      post "favourites/create_junkyard"
      post "favourites/destroy"
      post "favourites/destroy_favourite_lender"
      post "favourites/destroy_favourite_junkyard"

      #
      # api routes related to cart
      get "carts/all"
      post "carts/add_item"
      post "carts/remove_item"

      #
      # api routes related to checkout
      post "checkouts/create"
      get "checkouts/items"
      post "checkouts/update_rent_duration"
      post "checkouts/update_payment_information"
      get "checkouts/review"
      post "checkouts/confirmation"
      post "checkouts/update_status_item"

      #
      # api routes related to histories
      get "histories/my_transaction"
      get "histories/my_order"
      get "histories/my_wallet"
      post "histories/update_status"

      #
      # api routes releated to lender
      get "lenders/all"
      get "lenders/profile"

      #
      # api routes releated to notifications
      get "messages/all"
      get "messages/conversation"
      get "messages/conversation_by_receiver"
      get "messages/renter_conversation"
      get "messages/lender_conversation"
      post "messages/post_message"
      post "messages/reply_message"

      #
      # api routes releated to notifications
      get "notifications/all"
      post "notifications/test_notify"

      #
      # api routes related to payment
      get "payments/by_user"
      match "payments/ipn_notify", via: [:post]
      match "payments/thank_you", via: [:get, :post]
      post "payments/create"
      post "payments/update"
      post "payments/update_status"
      post "payments/delete"
      post "payments/lender/give_refund", to: "payments#give_refund"
      post "payments/renter/accepted_refund", to: "payments#accepted_refund"

      #
      # api routes related to reviews
      get "reviews/lender/all", to: "reviews#get_lender_all"
      get "reviews/renter/all", to: "reviews#get_renter_all"
      get "reviews/list" => 'reviews/list_all', to: "reviews#list_all"
      get "reviews/detail"
      post "reviews/lender/create", to: "reviews#post_lender_review"
      post "reviews/lender/update", to: "reviews#update_lender_review"
      post "reviews/renter/create", to: "reviews#post_renter_review"
      post "reviews/renter/update", to: "reviews#update_renter_review"
      post "reviews/delete"

      #
      # api routes related to virtual junk yard
      get "junkyard_products/all"
      get "junkyard_products/by_category"
      get "junkyard_products/by_favourite"
      get "junkyard_products/by_user"
      get "junkyard_products/detail"
      post "junkyard_products/like"
      post "junkyard_products/unlike"
      post "junkyard_products/upload_photo"
      post "junkyard_products/create"
      post "junkyard_products/update"
      post "junkyard_products/delete"

      #
      # api routes related to transfer request
      post "transfer_requests/create"
    end
  end

  get "/*id", to: "pages#show"
end