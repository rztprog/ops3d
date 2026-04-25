Rails.application.routes.draw do
  scope "(:locale)", locale: /fr|en/ do
    get "orders/new"
    get "orders/create"
    get "orders/show"
    get "orders/index"
    get "cart_items/create"
    get "cart_items/update"
    get "cart_items/destroy"
    get "carts/show"
    get "products/index"
    get "products/show"
    devise_for :users
    root to: "pages#home"
    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

    # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
    # Can be used by load balancers and uptime monitors to verify that the app is live.
    get "up" => "rails/health#show", as: :rails_health_check

    # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
    # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
    # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

    # Defines the root path route ("/")
    resources :products, only: [ :index, :show ]

    resource :cart, only: [ :show ]
    resources :cart_items, only: [ :create, :update, :destroy ]

    resources :orders, only: [ :new, :create, :show, :index ]

    namespace :admin do
      root "dashboard#index"
      resources :products
      resources :categories
      resources :orders, only: [ :index, :show, :update ]
    end

    resource :account, only: [ :show ], controller: "accounts"

    namespace :account do
      resources :orders, only: [ :index, :show ]
    end

    resources :orders do
      member do
        post :checkout
      end
    end

    post "stripe/webhooks", to: "stripe_webhooks#create"
  end
end
