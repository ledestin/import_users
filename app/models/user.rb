class User < ActiveRecord::Base
  belongs_to :reports_to_user, class_name: 'User', foreign_key: :parent_id

  validates :email_address, email: true

  def self.from_array user
    email, first, last = *user
    User.new email_address: email, first_name: first, last_name: last
  end

  def self.import_users users
    problem_users, unfinished_users = [], {}

    users.each do |user|
      begin
        u = from_array user
        u.save!

        _email, _first, _last, manager_email = *user
        unfinished_users[u] = manager_email if manager_email
      rescue ActiveRecord::RecordInvalid
        problem_users << u
      end
    end

    unfinished_users.each do |user, manager_email|
      next unless manager = User.find_by_email_address(manager_email)

      user.update_attribute :parent_id, manager.id
    end

    problem_users
  end
end
