defmodule AoC2025.Puzzle.Day5Sorted do
  def part2(input) do
    {ranges, _} = AoC2025.Puzzle.Day5.parse_input(input)

    ranges
    |> Enum.sort_by(fn {min_v, _} -> min_v end)
    |> dedupe_ranges()
    |> Enum.map(&range_size/1)
    |> Enum.sum()
  end

  defp range_size({min_v, max_v}) do
    max_v - min_v + 1
  end

  defp dedupe_ranges([{cx, cy}, {nx, ny} | rest]) do
    if nx <= cy do
      y = max(ny, cy)
      dedupe_ranges([{cx, y} | rest])
    else
      [{cx, cy} | dedupe_ranges([{nx, ny} | rest])]
    end
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
