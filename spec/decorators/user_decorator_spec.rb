# coding: utf-8
require 'spec_helper'

describe UserDecorator do
  let(:user) { User.new.extend UserDecorator }
  subject { user }
  it { should be_a User }

  describe '#full_name' do
    let(:user) { FactoryGirl.create(:user, first_name: 'Hiroshi', last_name: 'Yoshida') }
    subject { decorate(user).full_name }
    it { should eq('Hiroshi Yoshida') }
  end
end
