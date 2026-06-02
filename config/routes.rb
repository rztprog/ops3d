Rails.application.routes.draw do
  namespace :admin do
    get "users/index"
    get "users/show"
    get "settings/edit"
  end
  get "stripe_webhooks/create"
  scope "(:locale)", locale: /fr|en/ do
    devise_for :users
    root to: "pages#home"
    get "mentions-legales", to: "pages#legal", as: :legal
    get "cgv", to: "pages#terms", as: :terms
    get "faq", to: "pages#faq", as: :faq
    get "contact", to: "pages#contact", as: :contact
    get "about", to: "pages#about", as: :about
    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

    # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
    # Can be used by load balancers and uptime monitors to verify that the app is live.
    get "up" => "rails/health#show", as: :rails_health_check

    # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
    # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
    # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

    # Defines the root path route ("/")
    resources :guest_orders, only: [ :index ]

    resources :products, only: [ :index, :show ]

    resource :cart, only: [ :show ] do
      post :apply_promo_code
      delete :remove_promo_code
    end

    resources :cart_items, only: [ :create, :update, :destroy ]

    resources :orders, only: [ :new, :create, :show, :index ]

    namespace :admin do
      root "dashboard#index"
      resources :products
      resources :categories

      resources :products do
        delete :remove_image, on: :member
      end
      resources :categories
      resources :orders, only: [ :index, :show, :update ]
      resources :users, only: [ :index, :show ]

      resource :settings, only: [ :edit, :update ]
      resources :promo_codes, only: [ :create, :destroy ]
    end

    resource :account, only: [ :show ], controller: "accounts"

    namespace :account do
      resources :orders, only: [ :index, :show ]
    end

    resources :orders do
      member do
        post :checkout
      end

      resource :paypal_checkout, only: [ :create ], controller: "paypal_checkouts" do
        get :success
        get :cancel
      end
    end

    post "/stripe_webhooks", to: "stripe_webhooks#create"
    post "/paypal_webhooks", to: "paypal_webhooks#create"
  end
end
