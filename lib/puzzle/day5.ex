defmodule AoC2025.Puzzle.Day5 do
  def part1(input) do
    {ranges, ids} = parse_input(input)

    ids
    |> Enum.filter(&in_range(&1, ranges))
    |> Enum.count()
  end

  def part2(input) do
    {ranges, _} = parse_input(input)

    ranges
    |> Enum.reduce([], fn item, acc ->
      Enum.concat(crop_range(item, acc), acc)
    end)
    |> Enum.map(&range_size/1)
    |> Enum.sum()
  end

  defp range_size({min_v, max_v}) do
    max_v - min_v + 1
  end

  # Crops range such that it won't overlap with any of the ranges in the list
  # If needed, the range is split into multiple smaller ones
  @spec crop_range({integer(), integer()}, [{integer(), integer()}]) :: [{integer(), integer()}]
  defp crop_range({min_v, max_v}, [{min_acc, max_acc} | _])
       when min_v >= min_acc and max_v <= max_acc do
    # Full overlap - the range is already fully included in the list
    []
  end

  defp crop_range({min_v, max_v}, [{min_acc, max_acc} | rest])
       when min_v < min_acc and max_v > max_acc do
    # Inner overlap - split the range into two parts
    Stream.concat(crop_range({min_v, min_acc - 1}, rest), crop_range({max_acc + 1, max_v}, rest))
  end

  defp crop_range({min_v, max_v}, [{min_acc, max_acc} | rest])
       when max_v < min_acc or min_v > max_acc do
    # No overlap - just add the range to the list
    crop_range({min_v, max_v}, rest)
  end

  defp crop_range({min_v, max_v}, [{min_acc, _} | rest]) when min_v < min_acc do
    # Start of the range is before the current range - crop the end of the range
    crop_range({min_v, min(max_v, min_acc - 1)}, rest)
  end

  defp crop_range({min_v, max_v}, [{_, max_acc} | rest]) when max_v > max_acc do
    # End of the range is after the current range - crop the start of the range
    crop_range({max(min_v, max_acc + 1), max_v}, rest)
  end

  defp crop_range({min_v, max_v}, []) do
    # No more ranges to check - just return the original range
    [{min_v, max_v}]
  end

  defp in_range(id, [{min_v, max_v} | _]) when id >= min_v and id <= max_v do
    true
  end

  defp in_range(id, [_ | rest]) do
    in_range(id, rest)
  end

  defp in_range(_, []) do
    false
  end

  def parse_input(input) do
    {ranges, ["" | ids]} =
      input
      |> Enum.map(&String.trim/1)
      |> Enum.split_while(&(&1 != ""))

    ranges =
      ranges
      |> Enum.map(&String.split(&1, "-", trim: true))
      |> Enum.map(fn [a, b] -> {String.to_integer(a), String.to_integer(b)} end)

    ids =
      ids
      |> Enum.map(&String.to_integer/1)

    {ranges, ids}
  end

  import AoC2025.Runner
  defrunner(Part1, id: "day05", name: "Day 5 - Part 1", do: part1)
  defrunner(Part2, id: "day05", name: "Day 5 - Part 2", do: part2)
end
