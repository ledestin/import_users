class User < ActiveRecord::Base
  belongs_to :reports_to_user, class_name: 'User', foreign_key: :parent_id

  validates :email_address, email: true

  def self.import_users user_arrays
    UserImporter.new(user_arrays).call
  end
end
