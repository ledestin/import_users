require 'rails_helper'

describe UserImporter do
  let(:user_without_manager) { ['a@example.com', 'John', 'Doe'] }
  let(:manager) { ['manager@example.com', 'Mike', 'Bolton', 'ceo@example.com'] }
  let(:user_with_manager) do
    ['user@example.com', 'John', 'Doe', manager.first]
  end

  describe '.from_array' do
    it 'creates new user that has no manager' do
      user = UserImporter.from_array user_without_manager

      expect(user.email_address).to eq 'a@example.com'
      expect(user.first_name).to eq 'John'
      expect(user.last_name).to eq 'Doe'
      expect(user.parent_id).to be_nil
    end

    it 'creates new user that has manager' do
      user = UserImporter.from_array user_with_manager

      expect(user.email_address).to eq 'user@example.com'
      expect(user.first_name).to eq 'John'
      expect(user.last_name).to eq 'Doe'
      expect(user.parent_id).to be_nil
    end
  end
end
