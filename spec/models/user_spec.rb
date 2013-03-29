require 'spec_helper'

describe User do
  describe 'validation' do
    let(:user) { FactoryGirl.build(:user) }
    it { user.should be_valid }

    describe '#login_name' do
      it 'is required' do
        user.login_name = nil
        user.should have(1).error_on(:login_name)
      end

      it 'is unique' do
        another_user = FactoryGirl.create(:user, login_name: 'hrysd')
        user.login_name = 'hrysd'
        user.should have(1).error_on(:login_name)
      end
    end

    describe '#email' do
      it 'is required' do
        user.email = nil
        user.should have(1).error_on(:email)
      end

      it 'is unique' do
        another_user = FactoryGirl.create(:user, email: 'hoge@hoge.com')
        user.email = 'hoge@hoge.com'
        user.should have(1).error_on(:email)
      end
    end

    describe '#first_name' do
      it 'is required' do
        user.first_name = nil
        user.should have(1).error_on(:first_name)
      end
    end

    describe '#last_name' do
      it 'is required' do
        user.last_name = nil
        user.should have(1).error_on(:last_name)
      end
    end
  end

  describe '#completed_percentage' do
    subject { user.completed_percentage}

    context 'when user finished all practices' do
      let(:user){ FactoryGirl.create(:programmer_with_finished_all_practices) }
      it { should eq(100) }
    end

    context 'when user finished some practices' do
      let(:user){ FactoryGirl.create(:programmer_with_finished_practices) }
      it { should eq(50) }
    end

    context 'when user does not finished anything' do
      let(:user){ FactoryGirl.create(:programmer_with_started_practices) }
      it { should eq(0) }
    end
  end

  describe '#full_name' do
    subject { user.full_name }
    let(:user) { FactoryGirl.create(:user, last_name: 'Yoshida', first_name: 'Hiroshi') }

    it { should eq('Yoshida Hiroshi') }
  end
end
