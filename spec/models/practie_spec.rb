require 'spec_helper'

describe Practice do
  describe 'validation' do
    let(:practice) { FactoryGirl.build(:practice) }
    it { practice.should be_valid }

    describe '#title' do
      it 'is required' do
        practice.title = nil
        practice.should have(1).error_on(:title)
      end
    end

    describe '#description' do
      it 'is reuiqred' do
        practice.description = nil
        practice.should have(1).error_on(:description)
      end
    end

    describe '#goal' do
      it 'is required' do
        practice.goal = nil
        practice.should have(1).error_on(:goal)
      end
    end
  end
end
