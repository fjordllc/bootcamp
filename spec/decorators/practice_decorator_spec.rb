# coding: utf-8
require 'spec_helper'

describe PracticeDecorator do
  let(:practice) { Practice.new.extend PracticeDecorator }
  subject { practice }
  it { should be_a Practice }
end
