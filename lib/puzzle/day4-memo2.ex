defmodule AoC2025.Puzzle.Day4MemoV2 do
  @table :grid_store

  def init() do
    ensure_table!()
  end

  def part1(input) do
    grid =
      input
      |> Enum.map(&parse_line/1)
      |> prepare_cached_grid()

    Enum.sum(grid_at(grid, 0)) - Enum.sum(grid_at(grid, 1))
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

    grid_id = :erlang.unique_integer([:monotonic, :positive])
    :ets.insert(@table, {grid_id, {max_x, max_y}})

    grid
    |> Enum.with_index()
    |> Enum.each(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.each(fn {v, x} -> :ets.insert(@table, {{grid_id, 0, y, x}, v}) end)
    end)

    grid_id
  end

  defp changes_max(grid) do
    [{last, _, _}] =
      Stream.zip([
        Stream.iterate(0, &(&1 + 1)),
        Stream.iterate(0, &(&1 + 1)) |> Stream.map(&grid_at(grid, &1)) |> Stream.map(&Enum.sum/1),
        Stream.iterate(1, &(&1 + 1)) |> Stream.map(&grid_at(grid, &1)) |> Stream.map(&Enum.sum/1)
      ])
      |> Stream.filter(fn {_, prev, next} -> prev == next end)
      |> Enum.take(1)

    Enum.sum(grid_at(grid, 0)) - Enum.sum(grid_at(grid, last))
  end

  defp grid_at(grid_id, n) do
    case :ets.lookup(@table, {grid_id, n}) do
      [{{^grid_id, ^n}, result}] ->
        result

      _ ->
        [{^grid_id, {max_x, max_y}}] = :ets.lookup(@table, grid_id)
        r = for y <- 0..max_y, x <- 0..max_x, do: point_at(grid_id, x, y, n)
        :ets.insert(@table, {{grid_id, n}, r})
        r
    end
  end

  defp point_at(grid_id, x, y, n) when n >= 0 do
    case {:ets.lookup(@table, {grid_id, n, y, x}), n} do
      {[{{^grid_id, ^n, ^y, ^x}, result}], _} ->
        result

      {_, 0} ->
        0

      {_, n} ->
        c = count_at(grid_id, x, y, n - 1)

        r =
          if c < 4 do
            0
          else
            1
          end

        :ets.insert(@table, {{grid_id, n, y, x}, r})
        r
    end
  end

  defp count_at(grid, x, y, n) do
    p = fn x, y -> point_at(grid, x, y, n) end

    if p.(x, y) == 0 do
      0
    else
      p.(x - 1, y - 1) + p.(x, y - 1) + p.(x + 1, y - 1) + p.(x - 1, y) + p.(x + 1, y) +
        p.(x - 1, y + 1) + p.(x, y + 1) + p.(x + 1, y + 1)
    end
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

  defp ensure_table! do
    case :ets.whereis(@table) do
      :undefined ->
        try do
          :ets.new(@table, [
            :set,
            :named_table,
            :public,
            read_concurrency: true,
            write_concurrency: true
          ])
        rescue
          ArgumentError ->
            # Table was created by another process in the meantime
            :ets.whereis(@table)
        end

      tid ->
        tid
    end
  end

  import AoC2025.Runner
  defrunner(Part1, id: "day4", name: "Day 4 (functional with memoization v2) - Part 1", do: part1)
  defrunner(Part2, id: "day4", name: "Day 4 (functional with memoization v2) - Part 2", do: part2)
end
