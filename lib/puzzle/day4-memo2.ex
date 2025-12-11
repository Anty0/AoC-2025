defmodule AoC2025.Puzzle.Day4MemoV2 do
  def part1(input) do
    grid =
      input
      |> Enum.map(&parse_line/1)
      |> prepare_cached_grid()

    grid_at(grid, 0) - grid_at(grid, 1)
  end

  def part2(input) do
    input
    |> Enum.map(&parse_line/1)
    |> prepare_cached_grid()
    |> changes_max()
  end

  defp prepare_cached_grid(grid) do
    max_y = length(grid) - 1
    max_x = length(Enum.at(grid, 0)) - 1

    tid = :ets.new(:grid_store, [:set])

    grid
    |> Enum.with_index()
    |> Enum.each(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.each(fn {v, x} -> :ets.insert(tid, {{0, y, x}, v}) end)
    end)

    {tid, max_x, max_y}
  end

  defp changes_max(grid) do
    [{last, _, _}] =
      Stream.zip([
        Stream.iterate(0, &(&1 + 1)),
        Stream.iterate(0, &(&1 + 1)) |> Stream.map(&grid_at(grid, &1)),
        Stream.iterate(1, &(&1 + 1)) |> Stream.map(&grid_at(grid, &1))
      ])
      |> Stream.filter(fn {_, prev, next} -> prev == next end)
      |> Enum.take(1)

    grid_at(grid, 0) - grid_at(grid, last)
  end

  defp grid_at({tid, max_x, max_y}, n) do
    memoized(tid, n, fn ->
      for(y <- 0..max_y, x <- 0..max_x, do: point_at(tid, max_x, max_y, x, y, n)) |> Enum.sum()
    end)
  end

  defp point_at(tid, max_x, max_y, x, y, n) when n >= 0 do
    cond do
      x < 0 or y < 0 ->
        0

      x > max_x or y > max_y ->
        0

      true ->
        memoized(tid, {n, y, x}, fn ->
          if point_at(tid, max_x, max_y, x, y, n - 1) == 0 or
               count_at(tid, max_x, max_y, x, y, n - 1) < 4 do
            0
          else
            1
          end
        end)
    end
  end

  defp count_at(tid, max_x, max_y, x, y, n) do
    sum_neighbors(tid, max_x, max_y, x, y, n, 0, neighbors())
  end

  defp neighbors do
    [
      {-1, -1},
      {0, -1},
      {1, -1},
      {-1, 0},
      {1, 0},
      {-1, 1},
      {0, 1},
      {1, 1}
    ]
  end

  defp sum_neighbors(_, _, _, _, _, _, sum, _) when sum >= 4 do
    # When we know there are at least 4, we don't need to count others
    sum
  end

  defp sum_neighbors(tid, max_x, max_y, x, y, n, sum, [{dx, dy} | rest]) do
    sum = sum + point_at(tid, max_x, max_y, x + dx, y + dy, n)
    sum_neighbors(tid, max_x, max_y, x, y, n, sum, rest)
  end

  defp sum_neighbors(_, _, _, _, _, _, sum, []) do
    sum
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.to_charlist()
    |> Enum.map(&parse_character/1)
  end

  defp parse_character(ch) do
    case ch do
      ?@ -> 1
      ?. -> 0
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

  import AoC2025.Runner
  defrunner(Part1, id: "day04", name: "Day 4 (functional with memoization v2) - Part 1", do: part1)
  defrunner(Part2, id: "day04", name: "Day 4 (functional with memoization v2) - Part 2", do: part2)
end
