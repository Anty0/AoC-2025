defmodule AoC2025.Puzzle.Day4Memo do
  use Memoize

  def part1(input) do
    grid =
      input
      |> Enum.map(&parse_line/1)
      |> prepare_grid()

    Enum.sum(grid_at(grid, 0)) - Enum.sum(grid_at(grid, 1))
  end

  def part2(input) do
    input
    |> Enum.map(&parse_line/1)
    |> prepare_grid()
    |> changes_max()
  end

  defp prepare_grid(grid) do
    grid =
      grid
      |> Enum.map(&List.to_tuple/1)
      |> List.to_tuple()

    max_y = tuple_size(grid) - 1
    max_x = tuple_size(elem(grid, 0)) - 1

    {grid, max_x, max_y}
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

  defp grid_at({grid, max_x, max_y}, n) do
    Memoize.Cache.get_or_run({__MODULE__, :resolve, [max_x, max_y, n]}, fn ->
      for y <- 0..max_y, x <- 0..max_x, do: point_at({grid, max_x, max_y}, x, y, n)
    end)
  end

  defp point_at({grid, max_x, max_y}, x, y, 0) do
    cond do
      x < 0 || y < 0 ->
        0

      x > max_x || y > max_y ->
        0

      true ->
        grid
        |> elem(y)
        |> elem(x)
    end
  end

  defp point_at({grid, max_x, max_y}, x, y, n) when n > 3 do
    Memoize.Cache.get_or_run({__MODULE__, :resolve, [max_x, max_y, x, y, n]}, fn ->
      p = fn x, y -> point_at({grid, max_x, max_y}, x, y, n - 1) end

      cond do
        p.(x, y) == 0 ->
          0

        p.(x - 1, y - 1) + p.(x, y - 1) + p.(x + 1, y - 1) + p.(x - 1, y) + p.(x + 1, y) +
          p.(x - 1, y + 1) + p.(x, y + 1) + p.(x + 1, y + 1) < 4 ->
          0

        true ->
          1
      end
    end)
  end

  defp point_at({grid, max_x, max_y}, x, y, n) when n > 0 do
    p = fn x, y -> point_at({grid, max_x, max_y}, x, y, n - 1) end

    cond do
      p.(x, y) == 0 ->
        0

      p.(x - 1, y - 1) + p.(x, y - 1) + p.(x + 1, y - 1) + p.(x - 1, y) + p.(x + 1, y) +
        p.(x - 1, y + 1) + p.(x, y + 1) + p.(x + 1, y + 1) < 4 ->
        0

      true ->
        1
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

  import AoC2025.Runner
  defrunner(Part1, id: "day4", name: "Day 4 (functional with memoization) - Part 1", do: part1)
  defrunner(Part2, id: "day4", name: "Day 4 (functional with memoization) - Part 2", do: part2)
end
