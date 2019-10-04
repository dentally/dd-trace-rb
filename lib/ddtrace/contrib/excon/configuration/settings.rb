require 'ddtrace/contrib/configuration/settings'
require 'ddtrace/contrib/excon/ext'

module Datadog
  module Contrib
    module Excon
      module Configuration
        # Custom settings for the Excon integration
        class Settings < Contrib::Configuration::Settings
          option :analytics_enabled do |o|
            o.default { env_to_bool(Ext::ENV_ANALYTICS_ENABLED, false) }
            o.lazy true
          end

          option :analytics_sample_rate do |o|
            o.default { env_to_float(Ext::ENV_ANALYTICS_SAMPLE_RATE, 1.0) }
            o.lazy true
          end

          option :distributed_tracing, default: true
          option :error_handler
          option :service_name, default: Ext::SERVICE_NAME
          option :split_by_domain, default: false
        end
      end
    end
  end
end
