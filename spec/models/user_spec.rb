require 'rails_helper'

describe User do
  let(:user_without_manager) { ['a@example.com', 'John', 'Doe'] }

  describe '.import_user' do
    it 'imports user that has no manager' do
      User.import_user user_without_manager

      user = User.find_by_email_address('a@example.com')
      expect(user.email_address).to eq 'a@example.com'
      expect(user.first_name).to eq 'John'
      expect(user.last_name).to eq 'Doe'
      expect(user.parent_id).to be_nil
    end
  end
end
