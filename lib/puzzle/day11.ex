defmodule AoC2025.Puzzle.Day11 do
  def part1(input) do
    input
    |> Enum.map(&parse_line/1)
    |> build_map()
    |> all_paths(:you, [:out])
  end

  def part2(input) do
    map =
      input
      |> Enum.map(&parse_line/1)
      |> build_map()

    # Since we need to pass through some predefined points, we calculate path between these points
    # product of these paths represents number of possible paths.
    # Since the order doesn't matter we need to plan the path for both possible orders of points.
    path1 =
      all_paths(map, :svr, [:fft], [:dac]) *
        all_paths(map, :fft, [:dac], []) *
        all_paths(map, :dac, [:out], [:fft])

    path2 =
      all_paths(map, :svr, [:dac], [:fft]) *
        all_paths(map, :dac, [:fft], []) *
        all_paths(map, :fft, [:out], [:dac])

    path1 + path2
  end

  defp all_paths(map, from, targets, blocked \\ []) do
    tid = :ets.new(:grid_store, [:set])
    result = path_to(tid, map, from, targets, blocked)
    :ets.delete(tid)
    result
  end

  defp path_to(tid, map, current, targets, blocked) do
    # Since map doesn't contain any cycles, the result relies only on current position
    # (and the memoization is reset for each change of parameters)
    # To make part 2 possible, the `stop` list is used to virtually block some paths
    cond do
      Enum.member?(targets, current) ->
        1

      Enum.member?(blocked, current) ->
        0

      true ->
        memoized(tid, current, fn ->
          case map do
            %{^current => neighbors} ->
              Enum.sum_by(neighbors, &path_to(tid, map, &1, targets, blocked))

            _ ->
              0
          end
        end)
    end
  end

  defp memoized(tid, key, fun) do
    case :ets.lookup(tid, key) do
      [{^key, result}] ->
        result

      _ ->
        result = fun.()
        :ets.insert(tid, {key, result})
        result
    end
  end

  defp build_map([]) do
    %{}
  end

  defp build_map([{name, neighbors} | rest]) do
    map = build_map(rest)
    Map.put(map, name, neighbors)
  end

  defp parse_line(line) do
    [name, neighbors] =
      line
      |> String.trim()
      |> String.split(":", parts: 2)

    neighbors =
      neighbors
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_atom/1)

    {String.to_atom(name), neighbors}
  end

  import AoC2025.Runner
  defrunner(Part1P1, id: "day11.p1", name: "Day 11 - Part 1", do: part1)
  defrunner(Part2P2, id: "day11.p2", name: "Day 11 - Part 2", do: part2)
  defrunner(Part1Any, id: "day11.any", name: "Day 11 - Part 1", do: part1)
  defrunner(Part2Any, id: "day11.any", name: "Day 11 - Part 2", do: part2)
end
