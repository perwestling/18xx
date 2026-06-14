# Code Review Steering Guide - 18XX Game

*Last updated: June 14, 2026*
*Source: Lessons from PR reviews, including PR #12705*

---

## Overview

This document provides guidance for reviewing pull requests in the 18XX game repository. It captures patterns, common issues, and best practices identified through previous reviews.

**Target Audience**: Contributors and maintainers reviewing PRs for the 18xx.games project.

---

## Review Philosophy

### Core Principles

1. **Minimal Change**: Every PR should change only what's necessary to fix the issue or add the feature
2. **Preserve Existing Behavior**: Changes should not break other game variants or existing functionality
3. **Leverage Existing Patterns**: Use established codebase patterns before creating new mechanisms
4. **Test Coverage**: Bug fixes must include tests that reproduce the bug
5. **Code Clarity**: Complex logic must be well-commented (explain *why*, not *what*)

### Review Mindset

When reviewing a PR, ask:
- "Does this solve the stated problem?"
- "Could this break anything else?"
- "Is there a simpler way to achieve this?"
- "Will future maintainers understand this?"

---

## Pre-Review Checklist

Before diving into the code, verify:

- [ ] PR title clearly describes the change
- [ ] PR description explains the problem and solution
- [ ] PR references relevant issues (e.g., "Closes #11379")
- [ ] Author has tested the changes manually
- [ ] All existing tests pass (check CI status)

---

## Review Checklists

### For All PRs

#### Code Quality
- [ ] **Style**: Code follows `.rubocop.yml` standards
- [ ] **Naming**: Classes, methods, variables follow existing conventions
  - Game variants: `G18XXX::` prefix
  - Steps: `Engine::Step::` or variant-specific
  - Abilities: lowercase, descriptive (e.g., `cheater`, `blocks_hexes`)
- [ ] **Comments**: Non-obvious logic is explained with comments
- [ ] **Consistency**: Style matches surrounding codebase
- [ ] **No Debug Code**: No leftover `debug!`, `puts`, or `binding.irb`

#### Testing
- [ ] **Existing Tests Pass**: All 133+ existing fixture tests still pass
- [ ] **New Tests Added**: For bug fixes, a test reproduces the bug
- [ ] **Edge Cases**: Related edge cases are considered and tested
- [ ] **Manual Verification**: Complex scenarios have been manually verified

#### Documentation
- [ ] **Changelog**: If applicable, changelog entry is included
- [ ] **Code Comments**: New complex logic has explanatory comments
- [ ] **PR Description**: Clearly explains what and why

---

### For Bug Fix PRs

- [ ] **Root Cause Identified**: PR description explains the root cause
- [ ] **Reproduction Test**: New fixture test reproduces the exact bug scenario
- [ ] **Minimal Fix**: Only the necessary code is changed
- [ ] **No Side Effects**: Change doesn't affect other variants
- [ ] **Regression Prevention**: Test prevents this bug from recurring

**Example from PR #12705**:
```
Bug: TR home token blocked when Nepal is full
Root Cause: Danish EIC's cheater flag bypassed TR's reservation
Fix: Route cheater tokens to @extra_tokens
Test: Should add fixture reproducing Nepal-full scenario
```

---

### For New Feature PRs

- [ ] **Design Discussion**: Feature was discussed in Slack/issue before implementation
- [ ] **Backward Compatible**: Doesn't break existing game saves
- [ ] **Migration Plan**: If breaking changes, migration path is documented
- [ ] **Performance**: No performance bottlenecks introduced
- [ ] **All Variants**: Feature works correctly across all affected variants

---

### For Game Variant PRs

- [ ] **Inheritance**: Properly extends base classes
- [ ] **Variant Isolation**: Changes are scoped to the specific variant
- [ ] **No Base Class Changes**: Doesn't modify base classes unless absolutely necessary
- [ ] **Variant-Specific Tests**: Tests are in the variant's fixture directory
- [ ] **Meta Information**: `meta.rb` is updated with variant details

---

## Common Issues to Watch For

### 1. Cheater Flag Interactions ⚠️

**Pattern**: The `cheater` ability flag can bypass reservation checks, causing tokens to consume slots reserved for other entities.

**Symptoms**:
- Home tokens cannot be placed
- City slots are unexpectedly filled
- Token placement fails without clear reason

**Review Check**:
- When `cheater` ability is involved, verify reservation systems are preserved
- Look for `@extra_slot` mechanism usage
- Check if variant has reserved city slots

**Solution Pattern** (from PR #12705):
```ruby
# In variant-specific step
if action.entity.ability&.cheater && @game.hex_by_id(action.hex).reserved_by?
  action.entity.ability.extra_slot = true
end
super  # Routes to @extra_tokens instead of consuming reserved slot
```

**Games Affected**: 18 India, and potentially others with reserved slots

---

### 2. Token Placement Issues

**Common Problems**:
- Tokens placed in wrong city slots
- Reservation checks bypassed
- Extra tokens not handled correctly

**Key Methods to Review**:
- `tokenable?` - Checks if token can be placed
- `process_place_token` - Handles placement logic
- `reserved_by?` - Checks reservations

**Review Checklist**:
- [ ] Are all reservation checks preserved?
- [ ] Are `@extra_tokens` handled correctly?
- [ ] Does the variant have special token rules?
- [ ] Are home token placements protected?

---

### 3. Route Calculation Issues

**Common Problems**:
- Incorrect route revenue
- Routes not finding valid paths
- Train types not handled correctly

**Key Methods to Review**:
- `route` - Main route calculation
- `train` - Train-specific logic
- `connected_hexes` - Track connectivity

**Review Checklist**:
- [ ] Are all train types handled?
- [ ] Are track types (narrow, standard, etc.) considered?
- [ ] Are hex upgrades accounted for?
- [ ] Are variant-specific route rules applied?

---

### 4. Fixture Test Issues

**Common Problems**:
- Fixture doesn't reproduce the bug
- Test is too broad (catches unrelated issues)
- Test is too narrow (misses edge cases)

**Review Checklist**:
- [ ] Does the fixture set up the exact scenario?
- [ ] Does the test verify the fix works?
- [ ] Does the test verify the bug existed before?
- [ ] Are there tests for related edge cases?

**Good Fixture Example**:
```json
{
  "id": "12345",
  "description": "TR home token blocked when Nepal is full",
  "actions": [
    {"type": "place_token", "entity": "NCR", "hex": "M10", "slot": 0},
    {"type": "use_ability", "entity": "EIR", "ability": "Danish EIC"},
    {"type": "place_token", "entity": "EIR", "hex": "M10", "slot": 1},
    {"type": "float", "entity": "TR"},
    {"type": "place_token", "entity": "TR", "hex": "M10", "slot": 2}
  ],
  "expected": {"success": true, "token_placed": true}
}
```

---

### 5. Step Override Issues

**Common Problems**:
- Override doesn't call `super` when it should
- Override breaks base functionality
- Override doesn't handle all cases

**Review Checklist**:
- [ ] Does the override call `super` at the right time?
- [ ] Are all base class methods still functional?
- [ ] Are variant-specific cases properly handled?
- [ ] Are there tests for the override behavior?

---

### 6. Ability Interaction Issues

**Common Problems**:
- Abilities don't work together correctly
- Ability timing is wrong
- Ability affects wrong entities

**Key Methods to Review**:
- `use_ability` - Ability activation
- `ability_desc` - Ability description
- `setup_abilities` - Ability assignment

**Review Checklist**:
- [ ] Does the ability have clear, unique name?
- [ ] Is the ability description accurate?
- [ ] Does the ability work with other abilities?
- [ ] Are there tests for ability interactions?

---

## Variant-Specific Review Guide

### General Pattern

When reviewing changes to a specific game variant (e.g., `g_18india`):

1. **Identify the variant directory**: `lib/engine/game/g_<variant>/`
2. **Check what's changed**: Files modified in that directory
3. **Review base class usage**: Ensure it properly extends base classes
4. **Check variant isolation**: Verify changes don't affect other variants
5. **Review variant tests**: Tests should be in `public/fixtures/<variant>/`

### Common Variant Files

| File | Review Focus |
|------|--------------|
| `game.rb` | Main game logic, round structure |
| `entities.rb` | Variant-specific corporations/companies |
| `map.rb` | Map configuration, hexes, locations |
| `meta.rb` | Variant metadata, name, description |
| `step/*.rb` | Variant-specific step overrides |
| `version.rb` | Version information |

---

## Review Template

Use this template when reviewing PRs:

```markdown
## Code Review: PR #[number](link)

### Summary
- **Author**: @username
- **Title**: [PR title]
- **Files Changed**: X files, Y lines
- **Type**: [Bug Fix / New Feature / Refactor / Documentation]

### Overall Assessment
- [ ] LGTM ✅
- [ ] Needs Work ⚠️
- [ ] Blocked 🚫

### Analysis

#### Problem
- [ ] Root cause clearly identified
- [ ] Problem description is accurate
- [ ] Issue reference included

#### Solution
- [ ] Minimal change (only what's necessary)
- [ ] Uses existing codebase patterns
- [ ] Preserves existing behavior
- [ ] No breaking changes

#### Code Quality
- [ ] Follows RuboCop style
- [ ] Clear naming conventions
- [ ] Well-commented (why, not what)
- [ ] Consistent with codebase
- [ ] No leftover debug code

#### Testing
- [ ] All existing tests pass
- [ ] New test reproduces bug (if bug fix)
- [ ] Edge cases covered
- [ ] Manual verification completed

### Specific Feedback

**Strengths**:
1. [Strength 1]
2. [Strength 2]

**Concerns**:
1. [Concern 1]
2. [Concern 2]

**Suggestions**:
1. [Suggestion 1]
2. [Suggestion 2]

### Approval
- [ ] **Ready to merge** 🚀
- [ ] **Needs changes** 🔧 (list required changes)
- [ ] **Blocked** 🚫 (explain why)
```

---

## Quick Review Script

For a quick initial assessment:

```bash
# Check files changed
cd /home/per/my_18xx/18xx
git diff --stat origin/master

# Run RuboCop on changed files
docker compose exec rack bundle exec rubocop $(git diff --name-only origin/master | grep '\.rb$')

# Run tests for affected variants
# (Identify variant from file paths, then run its tests)
docker compose exec rack rspec spec/lib/engine/game/fixtures_spec.rb -e '<variant_name>'

# Check for common issues
grep -n "cheater" $(git diff --name-only origin/master)
grep -n "reservation" $(git diff --name-only origin/master)
grep -n "tokenable" $(git diff --name-only origin/master)
```

---

## Red Flags Requiring Extra Scrutiny

| Red Flag | Why It Matters | What to Check |
|----------|----------------|---------------|
| Changes to base classes | Affects all variants | Test all variants, not just the target |
| `cheater` ability used | May bypass reservations | Verify `@extra_slot` handling |
| Token placement logic | Easy to break reservations | Check all reservation systems |
| Route calculation changes | Complex, easy to break | Test with multiple train types |
| No new tests | Bug may recur | Request reproduction test |
| >50 lines changed | May be over-engineered | Ask if there's a simpler solution |
| Multiple variants affected | High risk of side effects | Test all affected variants |
| Changes to `tokenable?` | Critical for token placement | Verify all reservation checks |
| `super` not called | May break base functionality | Check inheritance chain |

---

## Learning from Past Reviews

### PR #12705: [18 India] Fix TR home token blocked when Nepal is full

**What Went Well**:
- ✅ Minimal change (2 files, 28 lines)
- ✅ Correct root cause identification
- ✅ Elegant solution using existing `@extra_slot` mechanism
- ✅ Well-commented code
- ✅ All existing tests passed
- ✅ Manual verification documented

**What Could Improve**:
- ⚠️ Missing specific fixture test reproducing the bug
- ⚠️ Could have mentioned the `@extra_slot` pattern in PR description

**Key Lesson**: When `cheater` ability interacts with reservations, always verify that reserved slots (like TR's home token) are preserved. Use `@extra_slot` to route special tokens without consuming reserved slots.

---

## Resources

### External Documentation
- [Ruby Documentation](https://ruby-doc.org/)
- [RSpec Documentation](https://rspec.info/)
- [RuboCop Documentation](https://rubocop.readthedocs.io/)
- [18xx BoardGameGeek](https://boardgamegeek.com/boardgamefamily/19/series-18xx)

### Internal Documentation
- [REPOSITORY.md](./REPOSITORY.md) - Repository structure overview
- [DEVELOPMENT.md](./DEVELOPMENT.md) - Development setup guide
- [TILES.md](./TILES.md) - Tile development details
- [public/fixtures/README.md](./public/fixtures/README.md) - Fixture test guide

---

## Document Metadata

- **Repository**: perwestling/18xx (fork of tobymao/18xx)
- **Primary Use**: Code review guidance for contributors
- **Maintainer**: perwestling
- **Related Documents**: REPOSITORY.md, DEVELOPMENT.md

---

*This document provides steering for code reviews based on lessons learned from previous PRs, including PR #12705.*
