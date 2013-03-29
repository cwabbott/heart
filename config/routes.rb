Heart::Application.routes.draw do
  resources :metrics, :except => [:show] do
    collection do
      get :fetch_all
    end
  end

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

  resources :segments, :except => [:destroy] do
    collection do
      post :demographic
    end
  end
  
  resources :demographics, :except => [:destroy] do
  end

  resources :images, :except => [:destroy, :new, :update, :index]

  match '/metrics/:fulldate/fetch/:attribute', :controller => :metrics, :action => :fetch, :as => "fetch_attribute", :via => :get
  match '/metrics/:fulldate/:enddate/fetch/:attribute', :controller => :metrics, :action => :fetch, :as => "fetch_range_attribute", :via => :get
  match '/metrics/:fulldate/show/', :controller => :metrics, :action => :show, :as => "show_metric", :via => :get

  root :controller => "dashboards", :action => "default"

  # See how all your routes lay out with "rake routes"
end
