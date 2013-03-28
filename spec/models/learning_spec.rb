require 'spec_helper'

describe Learning do
  describe 'validation' do
    let(:learning) { FactoryGirl.build(:learning) }
    it { learning.should be_valid }

    describe '#user' do
      it 'is required' do
        learning.user_id = nil
        learning.should have(1).error_on(:user_id)
      end
    end

    describe '#practice' do
      it 'is required' do
        learning.practice_id = nil
        learning.should have(1).error_on(:practice_id)
      end
    end
  end
end
