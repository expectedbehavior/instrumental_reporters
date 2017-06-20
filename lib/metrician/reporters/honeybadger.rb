module Metrician
  class Honeybadger < Reporter

    def self.enabled?
      !!defined?(::Honeybadger) &&
        Metrician.configuration[:exception][:enabled]
    end

    def instrument
      ::Honeybadger::Agent.class_eval do
        def notify_with_metrician(exception, options = {})
          # We can differentiate whether or not we live inside a web
          # request or not by determining the nil-ness of:
          #   context_manager.get_rack_env
          notify_without_metrician(exception, options)
        ensure
          Metrician.increment("exception.raise") if Metrician.configuration[:exception][:raise][:enabled]
          Metrician.increment("exception.raise.#{Metrician.dotify(exception.class.name.underscore)}") if exception && Metrician.configuration[:exception][:exception_specific][:enabled]
        end
        alias_method :notify_without_metrician, :notify
        alias_method :notify, :notify_with_metrician
      end
    end

  end
end