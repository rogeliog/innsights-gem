module Innsights
  class Config::ControllerReport < Config::Report

    dsl_attr :event_name,  :catalyst 

    attr_accessor :controller, :action

    def initialize(catalyst)
      @controller, @action = catalyst.split('#')
      @catalyst = catalyst
      super()
    end

    def commit
      report, report_action = self, @action_name
      klass = controller_class
      unless klass.nil?
        Innsights.reports << report
        add_report_to_innsights(klass, report_action, report)
        add_after_filter(klass, action)
      end
    end


    def add_report_to_innsights(klass, report_action, report)
      klass.instance_eval do
        cattr_accessor :innsights_reports unless defined?(@@insights_reports)
        self.innsights_reports ||= {}
        self.innsights_reports[report_action] = report
        send :define_method, "report_to_innsights" do
          lambda {|r| self.innsights_reports[report_action].run(r)}.call(current_user)
        end
        send :after_filter, :report_to_innsights, only: :new
      end
    end

    def add_after_filter(klass, action)
      klass.class_eval do
        send :after_filter, :report_to_innsights, only: action.to_sym
      end
    end

    private

    def controller_class
      "#{@controller.titleize}Controller".safe_constantize
    end
  end
end


