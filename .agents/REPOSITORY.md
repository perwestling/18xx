# 18XX Game Repository Overview

*Last updated: June 14, 2026*

## Overview

This is the source code repository for [18xx.games](https://18xx.games), a free, open-source website for playing [18xx](https://boardgamegeek.com/boardgamefamily/19/series-18xx) board games online.

**Primary Language**: Ruby 3.2.3

**Framework**: Custom Ruby framework (not Rails) with Sinatra-like routing

---

## Technology Stack

| Component | Technology | Version/Details |
|-----------|------------|-----------------|
| Language | Ruby | 3.2.3 |
| Web Framework | Custom (api.rb, config.ru) | Sinatra-inspired |
| Database | PostgreSQL | Dockerized |
| ORM | Custom | models.rb, models/ |
| Frontend | JavaScript | Vanilla JS, no framework |
| Testing | RSpec | spec/ directory |
| Style Checking | RuboCop | .rubocop.yml |
| Containerization | Docker | docker-compose |
| Asset Pipeline | Custom | queue.rb, assets/ |
| Background Jobs | Redis | redis/ directory |

---

## Repository Structure

```
.
├── api.rb                    # Main application entry point
├── config.ru                 # Rack configuration
├── Gemfile                   # Ruby dependencies
├── Rakefile                  # Build tasks
├── README.md                 # Project overview
├── DEVELOPMENT.md            # Development setup guide
├── TILES.md                  # Tile development details
├── 
├── lib/                      # Core application code
│   └── engine/               # Game engine
│       ├── abilities.rb     # Company/corporation abilities
│       ├── action.rb        # Game actions
│       ├── bank.rb          # Bank logic
│       ├── company.rb       # Company model
│       ├── corporation.rb   # Corporation model
│       ├── debug.rb         # Debugging utilities
│       ├── game/            # Game variants
│       │   ├── g_1822/      # 1822 variant
│       │   ├── g_1835/      # 1835 variant
│       │   ├── g_18mex/     # 18MEX variant
│       │   ├── ...          # 30+ other variants
│       │   └── base.rb      # Base game class
│       ├── helper/          # Helper classes
│       ├── part/            # Game parts (tiles, tokens, etc.)
│       ├── round/           # Round/turn logic
│       ├── step/            # Game steps/phases
│       └── ability/         # Ability implementations
│
├── models/                   # Database models
├── models.rb                 # Model loader
├── db/                       # Database configuration
├── spec/                     # Test specifications
│   └── lib/                  # Engine tests
│       └── engine/           # Game engine tests
│           └── game/         # Game variant tests
│               └── fixtures_spec.rb  # Fixture-based tests
├── public/                   # Static assets and game fixtures
│   ├── fixtures/             # Game fixture JSON files
│   │   └── README.md         # Fixture documentation
│   ├── javascripts/          # Frontend JavaScript
│   └── stylesheets/          # CSS styles
├── routes/                   # API route definitions
├── assets/                   # Source assets (compiled to public/)
├── config/                   # Application configuration
├── scripts/                  # Utility scripts
│   ├── migrate_game.rb       # Game migration tool
│   └── import_game.rb        # Production game importer
├── migrate/                  # Database migrations
├── vendor/                   # Vendored dependencies
└── build/                    # Compiled assets
```

---

## Key Architectural Patterns

### 1. Game Variant Structure

Each game variant (1822, 1835, 18MEX, etc.) has its own directory under `lib/engine/game/`. The naming convention is `g_<variant_name>`.

```
lib/engine/game/g_1822/
├── game.rb              # Main game class
├── entities.rb          # Variant-specific entities
├── map.rb               # Map configuration
├── meta.rb              # Metadata (name, description, etc.)
├── step/                # Variant-specific steps
│   ├── buy_sell.rb      # Buy/sell phase
│   ├── route.rb         # Route handling
│   └── ...
└── version.rb           # Version information
```

### 2. Inheritance Hierarchy

```
Engine::Game::Base      # Base game class
    ├── Engine::Game::G1822::Game
    ├── Engine::Game::G1835::Game
    ├── Engine::Game::G18MEX::Game
    └── ... (all variants)
```

### 3. Step System

The game flow is controlled by a step system. Each step handles a specific phase of gameplay:

- `Engine::Step::Base` - Base step class
- `Engine::Step::BuySell` - Buy/sell shares
- `Engine::Step::Route` - Route building
- `Engine::Step::Dividend` - Dividend payout
- Variant-specific steps override base behavior as needed

### 4. Ability System

Corporations and companies can have special abilities:

- Defined in `lib/engine/abilities.rb`
- Implemented in `lib/engine/ability/`
- Each ability is a module that can be included in entities
- Common abilities: `cheater`, `blocks_hexes`, `extra_token`, etc.

### 5. Fixture-Based Testing

Game states are tested using JSON fixtures:
- Stored in `public/fixtures/`
- Each test file is a complete game state snapshot
- Tests verify that actions produce expected results
- Run with: `rspec spec/lib/engine/game/fixtures_spec.rb -e '<folder> <name>'`

### 6. Title and Variant Inheritance Pattern

The codebase follows a hierarchical pattern for game titles and their variants:

**Base Code**: `Engine::Game::Base` provides the foundation that all titles build upon.

**Title Implementation**: Each game title (e.g., 1880, 1822, 1835) implements its specific rules:
- Main file: `lib/engine/game/g_<title>/game.rb` (e.g., `g_1880/game.rb`)
- Metadata: `lib/engine/game/g_<title>/meta.rb` defines the title name and description
- Map configuration: `lib/engine/game/g_<title>/map.rb`
- Entities: `lib/engine/game/g_<title>/entities.rb` for corporations and companies
- Steps: `lib/engine/game/g_<title>/step/` contains step overrides
- Version: `lib/engine/game/g_<title>/version.rb`

**Variant Inheritance**: Variants can extend other titles. For example:
- `g_1880` - Base title (1880 China)
- `g_1880_romania` - Variant that extends 1880
- `g_1880_romania_transilvania` - Variant that extends 1880 Romania

This creates a chain: `Base -> 1880 -> 1880 Romania -> 1880 Romania Transilvania`

Each variant in the chain can:
- Override steps from parent titles
- Add new step implementations
- Modify game configuration
- Extend entities and abilities

**Testing Structure**:
- Unit tests: `spec/lib/engine/game/g_<title>/game_spec.rb`
- Integration tests: JSON fixture files in `public/fixtures/<title>/`

This pattern allows variants to reuse and extend parent title functionality while maintaining clean separation of concerns.

### 7. Adding a New Variant - Example Workflow

The `feature/1880_romania_transilvania` branch (commit a2e69f) demonstrates how to add a new variant:

**Step 1: Update Welcome View**
- Modify `assets/app/view/welcome.rb` to display the welcome message on 18xx.games (production)
- Local development server runs on `http://localhost:9292`

**Step 2: Register the Variant**
- Add the new variant to its parent title's `meta.rb` file
- For 1880 Romania Transilvania: add to `lib/engine/game/g_1880_romania/meta.rb`
- Note: Separate titles (like `g_1880` and `g_1880_romania`) do NOT modify each other's meta.rb files

**Step 3: Create Variant Files**
- Create directory: `lib/engine/game/g_1880_romania_transilvania/`
- Add required files:
  - `game.rb` - Main game class
  - `meta.rb` - Variant metadata
  - `map.rb` - Map configuration
  - `entities.rb` - Variant-specific entities
  - `version.rb` - Version information
  - `step/` directory - Variant-specific step overrides
- Add unit tests: `spec/lib/engine/game/g_1880_romania_transilvania/game_spec.rb`
- Add integration test fixtures: `public/fixtures/1880_romania_transilvania/`

This workflow applies to any new variant being added to the codebase.

### 8. Rounds and Steps Architecture

Each running game consists of a set of **rounds**, and each round contains a set of **steps**. This hierarchy is defined in the title's `game.rb` file.

**Directory Structure**:
- `step/` - Contains step overrides or new step implementations for the title
- `round/` - Contains round overrides or new round implementations for the title
- If these directories are absent, the title uses base classes from `Engine::Round` and `Engine::Step`

**Round Definition**: In `game.rb`, methods like `operating_round` instantiate round classes and specify their steps:

```ruby
# From lib/engine/game/g_1880_romania/game.rb
def operating_round(round_num)
  G1880::Round::Operating.new(self, [
    Engine::Step::HomeToken,
    Engine::Step::Exchange,
    Engine::Step::DiscardTrain,
    G1880Romania::Step::Assign,
    G1880Romania::Step::SpecialChoose,
    G1880Romania::Step::Track,
    G1880::Step::Token,
    G1880Romania::Step::Route,
    G1880::Step::Dividend,
    G1880Romania::Step::BuyTrain,
    G1880::Step::CheckFIConnection,
  ], round_num: round_num)
end
```

**Inheritance Pattern for Rounds**:
- Base: `Engine::Round::Operating` (or other base round classes)
- Title override: `G1880::Round::Operating` (extends base, located in `g_1880/round/`)
- Variant override: Can reference parent title's rounds (e.g., 1880 Romania uses `G1880::Round::Operating`)

**Inheritance Pattern for Steps**:
- Base: `Engine::Step::BuyTrain`
- Parent title override: `G1880::Step::BuyTrain` (extends base, located in `g_1880/step/`)
- Variant override: `G1880Romania::Step::BuyTrain` (extends parent's step)

This allows variants to selectively override only the steps or rounds they need to customize, while inheriting all other behavior from parent titles or the base classes.

---

## Development Environment

### Quick Start

```bash
# Clone the repository
git clone https://github.com/perwestling/18xx.git
cd 18xx

# Start Docker stack
make

# Access the application
# Open http://localhost:9292 in your browser
```

### Docker Commands

| Command | Description |
|---------|-------------|
| `make` | Start development stack (with build) |
| `make dev_up` | Start development stack |
| `make dev_up_b` | Start with rebuild |
| `make prod_up` | Start production stack |
| `make prod_up_b` | Start production with rebuild |
| `make prod_deploy` | Deploy to production |
| `docker compose exec rack bash` | Enter container shell |
| `docker compose exec rack irb` | Ruby REPL |

### Running Tests

```bash
# Run all tests and RuboCop
docker compose exec rack rake

# Run specific fixture test
docker compose exec rack rspec spec/lib/engine/game/fixtures_spec.rb -e '1822 12345'

# Run RuboCop only
docker compose exec rack rake rubocop

# Auto-correct RuboCop issues
docker compose exec rack bundle exec rubocop -A
```

### Debugging

Add `debug!` calls in Ruby code or `debugger` in JavaScript to set breakpoints.

```ruby
# In any Ruby file
debug!  # Sets a breakpoint
```

---

## Important Files for Contributors

| File | Purpose |
|------|---------|
| `DEVELOPMENT.md` | Development setup, troubleshooting |
| `TILES.md` | Tile development guide |
| `public/fixtures/README.md` | Fixture test documentation |
| `.rubocop.yml` | Code style configuration |
| `Gemfile` | Dependencies |
| `Rakefile` | Build tasks |

---

## Common Game Concepts

### Entities
- **Corporation**: Player-controlled companies that build track and operate trains
- **Company**: Minor companies with special abilities
- **Share**: Ownership stake in a corporation
- **Train**: Vehicles that generate revenue
- **Token**: Markers placed on the map
- **Tile**: Map hexes with track configurations
- **Route**: Path that trains travel to generate revenue

### Game Phases
1. **Stock Round**: Buy/sell shares
2. **Operating Round**: Each corporation operates in turn
3. **End of Round**: Cleanup and preparation for next round

### Key Methods to Understand

| Method | Location | Purpose |
|--------|----------|---------|
| `tokenable?` | Various | Checks if a token can be placed |
| `process_place_token` | Step classes | Handles token placement |
| `cheater` | Ability | Allows bypassing some restrictions |
| `reservation` | Corporation | Reserved city slots for home tokens |
| `route` | Route classes | Calculates train routes |

---

## Variant-Specific Patterns

### General Pattern: Step Overrides (Illustrated by 18 India)

The pattern used in 18 India is a general approach applicable to all titles and variants:

The 18 India variant introduced a scenario where:
- TR (Tata Railways) has a reserved home token slot in Nepal
- Danish EIC's `cheater` ability bypassed the reservation check
- Solution: Added `G18India::Step::SpecialToken` to route cheater tokens to `@extra_tokens`

This illustrates the general pattern of:
- Variant-specific step overrides (applies to all titles/variants)
- Interaction between abilities and reservations
- Use of `@extra_slot` mechanism for handling special token placements

This same pattern is used throughout the codebase for any title or variant that needs custom step behavior.

### Pattern: Overriding Steps

```ruby
# In lib/engine/game/g_18india/step/special_token.rb
module G18India
  module Step
    class SpecialToken < Engine::Step::Base
      def process_place_token(action)
        # Custom logic for handling cheater tokens
        if action.entity.ability&.cheater && @game.hex_by_id(action.hex).reserved_by?
          action.entity.ability.extra_slot = true
        end
        super
      end
    end
  end
end
```

---

## Useful Commands Reference

```bash
# Format code
bundle exec rubocop -A

# Run specific test
docker compose exec rack rspec spec/lib/engine/game/fixtures_spec.rb -e '1860 19354'

# Import production game
docker compose exec rack irb
> load "scripts/import_game.rb"
> import_game(<game_id>)

# Migrate game state
docker compose exec rack irb
> load "scripts/migrate_game.rb"
> migrate_json('file.json')

# Profile performance
rake stackprof[spec/fixtures/18_chesapeake/1277.json]
```

---

## Repository Metadata

- **Upstream**: [github.com/tobymao/18xx](https://github.com/tobymao/18xx)
- **Fork**: [github.com/perwestling/18xx](https://github.com/perwestling/18xx)
- **Website**: [18xx.games](https://18xx.games)
- **License**: MIT (see LICENSE file)
- **Primary Maintainer**: tobymao
- **Contributors**: 200+ (see GitHub contributors)

---

*This document provides an overview of the repository structure and key patterns for contributors and reviewers.*
