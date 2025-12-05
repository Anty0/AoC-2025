defmodule AoC2025.Puzzle.Day5Sorted do
  # Inspired by: https://github.com/andesyv/aoc/blob/f646f6e15a258ed7c1e595b37941ce476d1932e6/aoc25/src/fifth.gleam

  def part2(input) do
    {ranges, _} = AoC2025.Puzzle.Day5.parse_input(input)

    ranges
    |> Enum.sort_by(fn {min_value, _} -> min_value end)
    |> dedupe_ranges()
    |> Enum.map(&range_size/1)
    |> Enum.sum()
  end

  defp range_size({min_value, max_value}) do
    max_value - min_value + 1
  end

  defp dedupe_ranges([{current_min, current_max}, {next_min, next_max} | rest])
       when next_min <= current_max do
    # Overlap - extend max and merge the two ranges
    new_max = max(next_max, current_max)
    dedupe_ranges([{current_min, new_max} | rest])
  end

  defp dedupe_ranges([{current_min, current_max}, {next_min, next_max} | rest]) do
    # No overlap - add current to the result and move on
    [{current_min, current_max} | dedupe_ranges([{next_min, next_max} | rest])]
  end

  defp dedupe_ranges([current]) do
    [current]
  end

  defp dedupe_ranges([]) do
    []
  end

  import AoC2025.Runner
  defrunner(Part2, id: "day5", name: "Day 5 (working with sorted ranges) - Part 2", do: part2)
end
