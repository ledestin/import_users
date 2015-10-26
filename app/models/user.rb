class User < ActiveRecord::Base
  belongs_to :reports_to_user, class_name: 'User', foreign_key: :parent_id

  validates :email_address, email: true

  def self.from_array user
    email, first, last = *user
    User.new email_address: email, first_name: first, last_name: last
  end

  def self.import_users users
    invalid_users, unfinished_users = [], {}

    users.each do |user|
      u = from_array user
      unless u.save
        invalid_users << u
      else
        _email, _first, _last, manager_email = *user
        unfinished_users[u] = manager_email if manager_email
      end
    end

    unfinished_users.each do |user, manager_email|
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
