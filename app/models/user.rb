class User < ActiveRecord::Base
  def admin?
    (role == 'admin') ? true : false
  end
end
