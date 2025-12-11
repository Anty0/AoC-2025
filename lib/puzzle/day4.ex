defmodule AoC2025.Puzzle.Day4 do
  def part1(input) do
    input
    |> Enum.map(&parse_line/1)
    |> zip_neighbors()
    |> filter_free_neighbors()
    |> Enum.count()
  end

  def part2(input) do
    input
    |> Enum.map(&parse_line/1)
    |> remove_free()
  end

  defp remove_free(grid) do
    found =
      grid
      |> zip_neighbors()
      |> filter_free_neighbors()

    case found do
      [] ->
        0

      found ->
        grid = remove_coordinates(grid, found)
        remove_free(grid) + length(found)
    end
  end

  defp remove_coordinates(grid, [{x, y} | rest]) do
    row = Enum.at(grid, y)
    row = List.replace_at(row, x, 0)
    grid = List.replace_at(grid, y, row)
    remove_coordinates(grid, rest)
  end

  defp remove_coordinates(grid, []) do
    grid
  end

  defp filter_free_neighbors(neighbors) do
    for [x, y, center | rest] <- neighbors,
        center == 1,
        Enum.sum(rest) < 4 do
      {x, y}
    end
  end

  defp zip_neighbors(grid) do
    Enum.zip([
      Stream.iterate(0, &(&1 + 1)),
      grid,
      [[] | grid] |> infinite([]),
      grid |> Stream.drop(1) |> infinite([])
    ])
    |> Enum.flat_map(fn {index_y, real, above, bellow} ->
      Enum.zip([
        Stream.iterate(0, &(&1 + 1)),
        Stream.repeatedly(fn -> index_y end),
        real,
        [0 | above] |> infinite(0),
        above |> infinite(0),
        above |> Stream.drop(1) |> infinite(0),
        [0 | bellow] |> infinite(0),
        bellow |> infinite(0),
        bellow |> Stream.drop(1) |> infinite(0),
        [0 | real] |> infinite(0),
        real |> Stream.drop(1) |> infinite(0)
      ])
      |> Enum.map(&Tuple.to_list/1)
    end)
  end

  defp infinite(list, value) do
    Stream.concat(
      list,
      Stream.repeatedly(fn -> value end)
    )
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
  defrunner(Part1, id: "day04", name: "Day 4 - Part 1", do: part1)
  defrunner(Part2, id: "day04", name: "Day 4 - Part 2", do: part2)
end
