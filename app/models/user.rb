class User < ActiveRecord::Base
  belongs_to :reports_to_user, class_name: 'User', foreign_key: :parent_id

  def self.import_user user
    email, first, last = *user
    User.create! email_address: email, first_name: first, last_name: last
  end

  def self.import_users users
    unfinished_users = {}

    users.each do |user|
      u = import_user user

      _email, _first, _last, manager_email = *user
      unfinished_users[u] = manager_email if manager_email
    end

    unfinished_users.each do |user, manager_email|
      next unless manager = User.find_by_email_address(manager_email)

      user.update_attribute :parent_id, manager.id
    end
  end
end
