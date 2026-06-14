---
# Ruby Engine Skill for 18xx
# This file is automatically read by Vibe due to .agents/ location
# Reference it from top-level AGENTS.md with: [see ./agents/ruby_engine.md]
---

## Skill: ruby_engine

**Purpose:** Understands Ruby coding conventions and patterns in the 18xx engine (`lib/engine/`)

**Scope:**
- Directory: `lib/engine/**/*.rb`
- Not: `assets/app/` (generated JS)

---

## Architecture

### Engine vs View
| Component | Location | Language | Role |
|-----------|----------|----------|------|
| Engine | `lib/engine/` | Ruby | Core game logic, state management, rules |
| View (Ruby source) | `assets/app/view/game/` | Ruby | UI logic (compiled to JavaScript) |
| View (JS output) | `public/assets/` | JavaScript | Generated browser UI |

**Note:** RuboCop checks all Ruby code (both `lib/engine/` and `assets/app/view/game/`), but the patterns in this skill focus on the Engine layer.

**Communication Flow:** View (Ruby) → Actions → Engine → State → View (JS)

---

## Code Patterns

### 1. Class Hierarchy
```
Engine::Game::<Title>::Game < Parent::Game < Engine::Game::Base
```

All game variants follow this inheritance chain.

**Example:**
```ruby
module Engine
  module Game
    module G1880Romania
      class Game < G1880::Game
        # ...
      end
    end
  end
end
```

### 2. Module Composition Pattern
Every game class includes three standard modules:

```ruby
include_meta(G1880Romania::Meta)    # Game metadata
include G1880Romania::Map           # Hex/tile definitions
include G1880Romania::Entities      # Corporations, companies, minors
```

### 3. Constants Style
```ruby
# frozen_string_literal: true

UPPER_SNAKE_CASE = value.freeze

PHASES = [
  { name: 'A1', train_limit: 4, tiles: %i[yellow] },
  # ...
].freeze

TRAINS = [
  { name: '2', distance: 2, price: 100, rusts_on: '4', num: 10 },
  # ...
].freeze
```

**Rules:**
- All constants end with `.freeze`
- Use `%i[]` for tile type arrays
- Use `%w[]` for string arrays
- Hash rockets for symbol keys (`'nodes' => ['town']`)

### 4. Lazy Memoization Helpers
Standard pattern for corporation/company lookups:

```ruby
def tr
  @tr ||= corporation_by_id('TR')
end

def consortiu
  @consortiu ||= company_by_id('P2')
end
```

**Naming convention:**
- Corporations: lowercase name (`tr`, `consortiu`, `danube_port`)
- Companies: lowercase name (`banater`, `remar`, `malaxa`, `rocket`)

### 5. Revenue Calculation Pattern
Always implemented as a pair:

```ruby
def revenue_for(route, stops)
  revenue = super
  revenue += 10 if danube_port_bonus?(route, stops)
  revenue
end

def revenue_str(route)
  str = super
  str += " + Danube Port Bonus (#{format_currency(10)})" if danube_port_bonus?(route)
  str
end
```

### 6. Event Handlers
Named with `event_` prefix and bang (`!`):

```ruby
def event_open_borders!
  @log << "-- Event: Borders opened, owner of #{consortiu.name} still receives payment for built crossings --"
  # ... modify borders ...
  clear_graph
end
```

**Rules:**
- Always log the event first
- Call `clear_graph` if map/tiles were modified
- Event types: `open_borders`, `remove_borders`, `float_30`, `communist_takeover`, etc.

### 7. Round/Step System
Each round type has a corresponding method:

```ruby
def new_draft_round
  Engine::Round::Draft.new(self, [G1880Romania::Step::SimpleDraft], reverse_order: false)
end

def stock_round
  G1880::Round::Stock.new(self, [
    Engine::Step::Exchange,
    G1880Romania::Step::SpecialChoose,
    G1880Romania::Step::BuySellParShares,
  ])
end

def operating_round(round_num)
  G1880::Round::Operating.new(self, [
    Engine::Step::HomeToken,
    Engine::Step::Exchange,
    G1880Romania::Step::Track,
    # ... more steps ...
  ], round_num: round_num)
end
```

**Round Types:** Draft, Auction, Stock, Operating

### 8. Tile Laying
```ruby
def tile_lays(entity)
  return [] unless can_build_track?(entity)

  tile_lays = [{ lay: true, upgrade: true }]
  return tile_lays if entity.minor? || !@phase.tiles.include?(:green)

  tile_lays << { lay: :not_if_upgraded, upgrade: false }
  tile_lays
end
```

---

## Ruby Style Guide

### Required
```ruby
# frozen_string_literal: true
```

### Strings
- **Single quotes** for string literals (RuboCop enforcement)
- Double quotes only when interpolation is needed

### Collections
- `%w[city offboard town]` for string arrays
- `%i[yellow green brown gray]` for symbol arrays
- Prefer `%i[]` over `[:a, :b, :c]`

### Constants
- `UPPER_SNAKE_CASE` naming
- Always append `.freeze`
- Group related constants together

### Methods
- `snake_case` naming
- `?` suffix for predicate methods
- `!` suffix for mutating methods

### Inheritance & Modules
- Prefer module inclusion over deep inheritance trees
- Always call `super` when overriding parent methods

---

## File Structure Convention

```
lib/engine/
├── game/
│   ├── <base>/
│   │   └── game.rb          # Base game (e.g., G1880)
│   ├── <title>/
│   │   ├── game.rb          # Main game class
│   │   ├── meta.rb          # Game metadata (name, description)
│   │   ├── map.rb           # Hex coordinates, borders, tiles
│   │   ├── entities.rb      # Corporations, companies, minors
│   │   └── step/            # Custom step classes
│   │       ├── assign.rb
│   │       ├── special_choose.rb
│   │       └── ...
│   └── ...
└── config/
    └── game/               # Game configuration files
```

---

## Adding a New Game Title

**Template:**
```ruby
# lib/engine/game/g_<new_title>/game.rb
module Engine
  module Game
    module GNewTitle
      class Game < ParentGame  # e.g., G1880::Game or Engine::Game::Base

        include_meta(GNewTitle::Meta)
        include GNewTitle::Map
        include GNewTitle::Entities

        # === Constants ===
        CURRENCY_FORMAT_STR = '$%s'
        CERT_LIMIT = { 3 => 20, 4 => 16, 5 => 14 }.freeze
        STARTING_CASH = { 3 => 500, 4 => 400, 5 => 350 }.freeze

        PHASES = [ ... ].freeze
        TRAINS = [ ... ].freeze

        # === Helper Methods ===
        def my_corporation
          @my_corporation ||= corporation_by_id('CORP')
        end

        def my_company
          @my_company ||= company_by_id('P1')
        end

        # === Event Handlers ===
        def event_my_custom_event!
          @log << "-- Event: My custom event triggered --"
          # ... implementation ...
        end

        # === Round Customization ===
        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::Exchange,
            GNewTitle::Step::CustomStep,
          ])
        end
      end
    end
  end
end
```

**Corresponding files:**
- `meta.rb` - Game metadata
- `map.rb` - Hex layout, borders, tiles
- `entities.rb` - Corporations, companies, starting setup

---

## Common Override Points

| Method | Purpose | When to Override |
|--------|---------|------------------|
| `new_*_round` | Customize round flow | Adding/removing steps, changing order |
| `revenue_for` | Add revenue bonuses | Port bonuses, special track revenue |
| `revenue_str` | Customize revenue display | Show bonus breakdown |
| `tile_lays` | Control tile laying | Special tile rules per entity |
| `event_*!` | Custom event logic | Title-specific event handling |
| `init_*` | Custom initialization | Special starting conditions |
