require 'rails_helper'

describe User do
  let(:invalid_email) { 'lala.com' }

  let(:user_without_manager) { ['a@example.com', 'John', 'Doe'] }
  let(:user_without_manager2) { ['b@example.com', 'John', 'Doe'] }
  let(:manager) { ['manager@example.com', 'Mike', 'Bolton', 'ceo@example.com'] }
  let(:ceo) { ['ceo@example.com', 'Peter', 'Gibbons'] }
  let(:user_with_manager) do
    ['user@example.com', 'John', 'Doe', manager.first]
  end
  let(:user_with_invalid_email) { [invalid_email, 'John', 'Doe'] }

  describe '.import_users' do
    context 'returns array:' do
      it 'empty if there are no errors' do
        problem_users = User.import_users [user_without_manager]
        expect(problem_users).to be_an_instance_of(Array)
        expect(problem_users).to be_empty
      end

      it 'contains active records if there are errors' do
        problem_users = User.import_users [user_with_invalid_email]
        expect(problem_users.size).to eq 1
        expect(problem_users.first).to be_an_instance_of(User)
        expect(problem_users.first).not_to be_valid
      end
    end

    it 'imports user and their manager' do
      User.import_users [user_with_manager, manager]

      user = User.find_by_email_address 'user@example.com'
      manager = User.find_by_email_address 'manager@example.com'
      expect(user).not_to be_nil
      expect(manager).not_to be_nil
      expect(user.parent_id).to eq manager.id
    end

    it 'imports user, manager and CEO' do
      User.import_users [user_with_manager, manager, ceo]

      user = User.find_by_email_address 'user@example.com'
      manager = User.find_by_email_address 'manager@example.com'
      ceo = User.find_by_email_address 'ceo@example.com'
      expect(user).not_to be_nil
      expect(manager).not_to be_nil
      expect(ceo).not_to be_nil
      expect(user.parent_id).to eq manager.id
      expect(manager.parent_id).to eq ceo.id
      expect(ceo.parent_id).to be_nil
    end

    it 'imports 2 users w/o managers' do
      User.import_users [user_without_manager, user_without_manager2]
      expect(User.count).to eq 2
    end

    context 'validatations:' do
      it 'email_address is valid' do
        user = User.new email_address: invalid_email
        expect(user).not_to be_valid
        expect(user.errors.messages[:email_address]).not_to be_nil
      end

      it 'email_address is required' do
        user = User.new
        expect(user).to be_invalid
        expect(user.errors.messages[:email_address]).not_to be_nil
      end

      it 'first_name and last_name are not required' do
        user = User.new email_address: 'a@example.com'
        expect(user).to be_valid
      end
    end
  end
end
