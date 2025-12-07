defmodule AoC2025.Puzzle.Day7 do
  def part1(input) do
    {count, _} = solve(input)
    count
  end

  def part2(input) do
    {_, active} = solve(input)
    Enum.sum(active)
  end

  defp solve(input) do
    header =
      input
      |> Stream.take(1)
      |> Enum.at(0)
      |> String.trim()
      |> String.to_charlist()

    body =
      input
      |> Stream.drop(1)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&String.to_charlist/1)

    initial_state = {0, header |> Enum.map(&parse_header_character/1)}
    Enum.reduce(body, initial_state, &apply_moves/2)
  end

  defp apply_moves(line, state) do
    {count, active, _} = apply_move(line, state, 0)
    {count, active}
  end

  defp apply_move([?^ | rest_line], {count, [current | rest_active]}, _) do
    # We hit the splitter - use the next and prev params to split the traffic
    # and increase count if any traffic reached the splitter
    {count, rest_active, _} = apply_move(rest_line, {count, rest_active}, current)
    count = if current > 0, do: count + 1, else: count
    {count, [0 | rest_active], current}
  end

  defp apply_move([_ | rest_line], {count, [current | rest_active]}, next) do
    # No splitter here - just propagate the traffic coming from current, prev and next
    {count, rest_active, prev} = apply_move(rest_line, {count, rest_active}, 0)
    {count, [next + prev + current | rest_active], 0}
  end

  defp apply_move([], {count, []}, 0) do
    {count, [], 0}
  end

  defp parse_header_character(?S), do: 1
  defp parse_header_character(_), do: 0

  import AoC2025.Runner
  defrunner(Part1, id: "day7", name: "Day 7 - Part 1", do: part1)
  defrunner(Part2, id: "day7", name: "Day 7 - Part 2", do: part2)
end
