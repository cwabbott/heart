Rails.application.routes.draw do

  mount Heart::Engine => "/heart", as: 'heart_engine'
end
