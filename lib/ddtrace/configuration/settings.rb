require 'ddtrace/configuration/base'

require 'ddtrace/ext/analytics'
require 'ddtrace/ext/distributed'
require 'ddtrace/ext/runtime'

require 'ddtrace/tracer'
require 'ddtrace/metrics'

module Datadog
  module Configuration
    # Global configuration settings for the trace library.
    class Settings
      include Base

      #
      # Configuration options
      #
      option :analytics_enabled do |o|
        o.default { env_to_bool(Ext::Analytics::ENV_TRACE_ANALYTICS_ENABLED, nil) }
        o.lazy true
      end

      option :report_hostname do |o|
        o.default { env_to_bool(Ext::NET::ENV_REPORT_HOSTNAME, false) }
        o.lazy true
      end

      option :runtime_metrics_enabled do |o|
        o.default { env_to_bool(Ext::Runtime::Metrics::ENV_ENABLED, false) }
        o.lazy true
      end

      option :propagation_extract_style do |o|
        o.default do
          # Look for all headers by default
          env_to_list(Ext::DistributedTracing::PROPAGATION_EXTRACT_STYLE_ENV,
                      [Ext::DistributedTracing::PROPAGATION_STYLE_DATADOG,
                       Ext::DistributedTracing::PROPAGATION_STYLE_B3,
                       Ext::DistributedTracing::PROPAGATION_STYLE_B3_SINGLE_HEADER])
        end

        o.lazy true
      end

      option :propagation_inject_style do |o|
        o.default do
          # Only inject Datadog headers by default
          env_to_list(Ext::DistributedTracing::PROPAGATION_INJECT_STYLE_ENV,
                      [Ext::DistributedTracing::PROPAGATION_STYLE_DATADOG])
        end

        o.lazy true
      end

      option :tracer do |o|
        o.default Tracer.new

        # Backwards compatibility for configuring tracer e.g. `c.tracer debug: true`
        o.helper :tracer do |options = nil|
          tracer = options && options.key?(:instance) ? set_option(:tracer, options[:instance]) : get_option(:tracer)

          tracer.tap do |t|
            unless options.nil?
              t.configure(options)
              t.class.log = options[:log] if options[:log]
              t.set_tags(options[:tags]) if options[:tags]
              t.set_tags(env: options[:env]) if options[:env]
              t.class.debug_logging = options.fetch(:debug, false)
            end
          end
        end
      end

      def distributed_tracing
        # TODO: Move distributed tracing configuration to it's own Settings sub-class
        # DEV: We do this to fake `Datadog.configuration.distributed_tracing.propagation_inject_style`
        self
      end

      def runtime_metrics(options = nil)
        runtime_metrics = get_option(:tracer).writer.runtime_metrics
        return runtime_metrics if options.nil?

        runtime_metrics.configure(options)
      end
    end
  end
end
