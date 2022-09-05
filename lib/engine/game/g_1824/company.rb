# frozen_string_literal: true

require_relative '../../company'

module Engine
  module Game
    module G1824
      class Company < Engine::Company
        attr_accessor :type, :stack

        def initialize(sym:, name:, **opts)
          @type = opts[:type]&.to_sym
          @stack = opts[:stack]
          super
        end
      end
    end
  end
end
