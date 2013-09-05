Heart::Engine.routes.draw do

  resources :dashboards, :except => [:destroy] do
    get :archive
    collection do
      get :default
      post :flotit
    end
  end
  
  resources :annotations, :except => [:destroy, :index] do
    collection do
      post :description
    end
  end
  
  resources :images, :only => [:create, :show]
  
  resources :metrics, :only => [:index]
  match '/metrics/:fulldate/fetch/:attribute', :controller => :metrics, :action => :fetch, :as => "fetch_attribute", :via => :get
  match '/metrics/:fulldate/:enddate/fetch/:attribute', :controller => :metrics, :action => :fetch, :as => "fetch_range_attribute", :via => :get
  match '/metrics/:fulldate/show/', :controller => :metrics, :action => :show, :as => "show_metric", :via => :get

  root :controller => "dashboards", :action => "default"
end
