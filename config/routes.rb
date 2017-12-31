Rails.application.routes.draw do
  
  get 'manage_freereg_images/access', :to => 'manage_freereg_images#access', :as => :access_freereg_image
  get 'manage_freereg_images/download', :to => 'manage_freereg_images#download', :as => :download_freereg_image
  get 'manage_freereg_images/view', :to => 'manage_freereg_images#view', :as => :view_freereg_image
  get 'manage_freereg_images/register_folders', :to => 'manage_freereg_images#register_folders', :as => :register_folders_freereg_image
  get 'manage_freereg_images/images', :to => 'manage_freereg_images#images', :as => :images_freereg_image
  get 'manage_freereg_images/create_folder', :to => 'manage_freereg_images#create_folder', :as => :create_folder_freereg_image
  get 'manage_freereg_images/upload_images', :to => 'manage_freereg_images#upload_images', :as => :upload_images_freereg_image
  get 'manage_freereg_images/remove_image', :to => 'manage_freereg_images#remove_image', :as => :remove_image_freereg_image
  get 'manage_freereg_images/close', :to => 'manage_freereg_images#close', :as => :close_freereg_image
  resources :manage_freereg_images
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root :to => 'manage_freereg_images#index'
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
