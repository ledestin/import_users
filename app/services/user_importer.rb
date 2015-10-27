class UserImporter
  def self.from_array user_array
    email, first, last = *user_array
    User.new email_address: email, first_name: first, last_name: last
  end

  def initialize user_arrays
    @user_arrays = user_arrays
    @invalid_users, @managed_users = [], {}
  end

  def call
    User.transaction do
      @user_arrays.each { |user_array| save_or_mark_as_invalid user_array }
      add_parent_id_to_saved_users
    end

    @invalid_users
  end

  private

  def add_parent_id_to_saved_users
    @managed_users.each do |user, manager_email|
      next unless manager = User.find_by_email_address(manager_email)

      user.update_attribute :parent_id, manager.id
    end
  end

  def save_or_mark_as_invalid user_array
    user = self.class.from_array user_array
    unless user.save
      @invalid_users << user
    else
      _email, _first, _last, manager_email = *user_array
      @managed_users[user] = manager_email if manager_email
    end
  end
end
