require 'spec_helper'

describe Innsights::Config::Report do

  before do 
    class Dummy; end
    Dummy.stub!(:after_create)
  end
  let(:report) { Innsights::Config::Report.new(Dummy) }
  
  describe '.initialize' do
    let(:default_obj) { Innsights::Config::Report.new(Dummy) }
    
    it 'sets the created_at default' do
      default_obj.created_at.should  == :created_at
    end
    it 'sets the event name default' do
      default_obj.event_name.should  == :create
    end
    it 'sets the report user default' do
      default_obj.report_user.should == :user
    end
    it 'sets the klass to param' do
      default_obj.klass.should == Dummy
    end
  end
  
  describe '#commit' do    
    it 'adds the report to applications reports array' do
      report.commit
      Innsights.reports.should include(report)
    end
    it 'defines innsights_reports for the reported class' do
      report.commit
      report.klass.should respond_to(:innsights_reports)
    end
    it 'associates event name with report object' do
      report.commit
      report.klass.innsights_reports[report.action_name].should == report
    end
    it 'send a block to after_create on the report klass' do
      report.klass.should_receive(:after_create)
      report.commit
    end
  end
  
  describe '#run' do
    before do
      @client = mock("Innsights::Client", :report => nil)
      Innsights::Action.stub!(:new) { mock("Innsights::Action", :as_hash => {}) }
      Innsights.stub!(:client) { @client }
    end
    it 'calls the report method of the gems client' do
      Innsights.enabled = true
      @client.should_receive(:report)
      report.run(nil)
    end
    it 'doesnt call the report method when configuration is disabled' do
      Innsights.enabled = false
      @client.should_not_receive(:report)
      report.run(nil)
    end
  end
  
end