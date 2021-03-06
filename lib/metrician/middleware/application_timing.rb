module Metrician
  module Middleware
    # RequestTiming and ApplicationTiming work in concert to time the middleware
    # separate from the request processing. RequestTiming should be the first
    # or near first middleware loaded since it will be timing from the moment
    # the the app server is hit and setting up the env for tracking the
    # middleware execution time. RequestTiming should be the last or near
    # last middleware loaded as it times the application execution (separate from
    # middleware).
    class ApplicationTiming

      def initialize(app)
        @app = app
      end

      def call(env)
        if Middleware.request_timing_required?
          start_time = Time.now.to_f
        end
        @app.call(env)
      ensure
        if Middleware.request_timing_required?
          env[ENV_REQUEST_TOTAL_TIME] ||= (Time.now.to_f - start_time)
        end
      end

    end
  end
end
