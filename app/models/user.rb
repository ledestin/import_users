class User < ActiveRecord::Base
  belongs_to :reports_to_user, class_name: 'User', foreign_key: :parent_id

  validates :email_address, email: true

  def self.from_array user_array
    email, first, last = *user_array
    User.new email_address: email, first_name: first, last_name: last
  end

  def self.import_users user_arrays
    invalid_users, managed_users = [], {}

    user_arrays.each do |user_array|
      user = from_array user_array
      unless user.save
        invalid_users << user
      else
        _email, _first, _last, manager_email = *user_array
        managed_users[user] = manager_email if manager_email
      end
    end

    managed_users.each do |user, manager_email|
      add_parent_id user, manager_email
    end

    invalid_users
  end

  private

  def self.add_parent_id user, manager_email
    return unless manager = User.find_by_email_address(manager_email)

    user.update_attribute :parent_id, manager.id
  end
end
