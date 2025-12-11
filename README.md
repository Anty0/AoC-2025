# Advent of Code 2025

Code in this repository was written during Advent of Code 2025

Weapon of choice: Elixir

## Usage

```bash
# One of the tests opens a lot of temporary files concurrently
# Make sure the ulimit is high enough:
ulimit -n 4096

# Test
mix test
# Run
mix run_app
# Build binary `aoc2025`
mix escript.build
```

## License

Code is licensed under GPL-3 - <https://www.gnu.org/licenses/gpl-3.0.en.html>
