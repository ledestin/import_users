require 'rails_helper'

describe User do
  let(:user_without_manager) { ['a@example.com', 'John', 'Doe'] }
  let(:manager) { ['manager@example.com', 'Mike', 'Bolton'] }
  let(:user_with_manager) do
    ['user@example.com', 'John', 'Doe', manager.first]
  end

  describe '.import_user' do
    it 'imports user that has no manager' do
      User.import_user user_without_manager

      user = User.find_by_email_address('a@example.com')
      expect(user.email_address).to eq 'a@example.com'
      expect(user.first_name).to eq 'John'
      expect(user.last_name).to eq 'Doe'
      expect(user.parent_id).to be_nil
    end

    it 'imports user that has manager' do
      User.import_user user_with_manager

      user = User.find_by_email_address('user@example.com')
      expect(user.email_address).to eq 'user@example.com'
      expect(user.first_name).to eq 'John'
      expect(user.last_name).to eq 'Doe'
      expect(user.parent_id).to be_nil
    end
  end

  describe '.import_users' do
    it 'imports user and their manager' do
      User.import_users [user_with_manager, manager]

      user = User.find_by_email_address 'user@example.com'
      manager = User.find_by_email_address 'manager@example.com'
      expect(user).not_to be_nil
      expect(manager).not_to be_nil
      expect(user.parent_id).to eq manager.id
    end
  end
end
