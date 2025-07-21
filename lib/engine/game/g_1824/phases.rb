# frozen_string_literal: true

module Engine
  module Game
    module G1824
      module Phases
        PHASES = [
          {
            name: '2',
            on: '2',
            train_limit: { PreStaatsbahn: 2, Coal: 2, Regional: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: { PreStaatsbahn: 2, Coal: 2, Regional: 4 },
            tiles: %i[yellow green],
            status: %w[may_exchange_coal_railways
                       may_exchange_mountain_railways],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { PreStaatsbahn: 2, Coal: 2, Regional: 3, Staatsbahn: 4 },
            tiles: %i[yellow green],
            status: %w[may_exchange_coal_railways],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: { PreStaatsbahn: 2, Regional: 3, Staatsbahn: 4 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: { Regional: 2, Staatsbahn: 3 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            train_limit: { Regional: 2, Staatsbahn: 3 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '10',
            on: '10',
            train_limit: { Regional: 2, Staatsbahn: 3 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze
      end
    end
  end
end
