# frozen_string_literal: true

require "contracts"
begin
  require "rails/railtie"
  module Contracts
    class Railtie < Rails::Railtie
      initializer "contracts.logger" do
        Contracts.configuration.logger ||= Rails.logger
      end

      config.to_prepare do
        # Contract wrapping is idempotent, making reloads safe for existing contracts.
        Contracts.configuration.enabled = true if Contracts.configuration.enabled.nil?
      end
    end
  end
rescue LoadError
  # Rails remains an optional dependency.
end
