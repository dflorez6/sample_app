SampleApp::Application.routes.draw do
  get "relationships/create"

  get "relationships/destroy"

  #---------------------
  # Defining resources
  #---------------------

  resources :users do
    member do                                             # The MEMBER method means that the routes respond to URIs containing the user id
      get :following, :followers                          # Adding following and followers actions to the Users controller. We use get to arrange for the URIs to respond to GET requests
    end
  end

  resources :sessions, only: [:new, :create, :destroy]    # There is no need for show or edit actions, so we limit the resource by using only:()
  resources :microposts, only: [:create, :destroy]        # Routes for the Microposts resource.
  resources :relationships, only: [:create, :destroy]      # Routes for the Relationships resource.

  # Root or Home or Index
  root to: 'static_pages#home'

  # Routes matches
  match '/signup',  to: 'users#new'                       # Here the route is matched to the NEW action in the USERS controller
  match '/signin',  to: 'sessions#new'                    # Here the route is matched to the NEW action in the SESSIONS controller
  match '/signout', to: 'sessions#destroy', via: :delete  # We use via: :delete to invoke HTTP DELETE Request


  match '/help',    to: 'static_pages#help'               # Here the routes are matched to the STATIC_PAGES controller
  match '/about',   to: 'static_pages#about'
  match '/contact', to: 'static_pages#contact'




  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
