class User < ActiveRecord::Base
  belongs_to :reports_to_user, class_name: 'User', foreign_key: :parent_id

  def self.import_user user
    email, first, last = *user
    User.create! email_address: email, first_name: first, last_name: last
  end
end
