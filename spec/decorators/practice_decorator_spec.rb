# coding: utf-8
require 'spec_helper'

describe PracticeDecorator do
  before do
    ActiveDecorator::ViewContext.current = ApplicationController.new.view_context
    ActiveDecorator::Decorator.instance.decorate practice
  end

  describe '#learning_status' do
    subject { practice.learning_status(user.id) }

    context 'when learning is not found' do
      let(:user) { FactoryGirl.create(:user) }
      let(:practice) { FactoryGirl.create(:practice, :for_programmer) }

      it { should eq("<button class=\"unstarted btn\" id=\"practice-#{practice.id}\">開始</button>") }
    end

    context 'when learning status is started' do
      let(:learning) { FactoryGirl.create(:active_learnings_for_programmer) }
      let(:user) { learning.user }
      let(:practice) { learning.practice }

      it { should eq("<button class=\"started btn\" id=\"practice-#{practice.id}\">完了</button>") }
    end

    context 'when learning status is completed' do
      let(:learning) { FactoryGirl.create(:completed_learnings_for_programmer) }
      let(:user) { learning.user }
      let(:practice) { learning.practice }

      it { should eq("<button class=\"complete btn\" id=\"practice-#{practice.id}\">済</button>") }
    end
  end

  describe '#for' do
    subject { practice.for }

    context 'when target everyone' do
      let(:practice) { FactoryGirl.create(:practice) }
      it { should eq('共通 課題') }
    end

    context 'when target programmer' do
      let(:practice) { FactoryGirl.create(:practice, :for_programmer) }
      it { should eq('プログラマー 課題')}
    end

    context 'when target designer' do
      let(:practice) { FactoryGirl.create(:practice, :for_designer) }
      it { should eq('デザイナー 課題') }
    end
  end
end
