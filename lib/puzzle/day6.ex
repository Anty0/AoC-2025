defmodule AoC2025.Puzzle.Day6 do
  def part1(input) do
    parse_input(input)
    |> Enum.map(&as_integers/1)
    |> Enum.map(&apply_operation/1)
    |> Enum.sum()
  end

  def part2(input) do
    parse_input(input)
    |> Enum.map(&as_topdown_integers/1)
    |> Enum.map(&apply_operation/1)
    |> Enum.sum()
  end

  defp parse_input(input) do
    lines = Enum.to_list(input)

    # Find columns which contain only spaces - the spot where
    # we should split the input into columns
    split_map =
      lines
      |> Enum.map(&String.to_charlist/1)
      |> Enum.reduce([], &to_columns/2)
      |> Enum.map(&Enum.all?(&1, fn x -> x == ?\s end))

    # Split the input into columns of charlists and
    # then separate operation marker
    lines
    |> Enum.map(&String.trim(&1, "\n"))
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&split_charlist(&1, split_map))
    |> Enum.reduce([], &to_columns/2)
    |> Enum.map(&as_operation/1)
  end

  defp split_charlist(line, split_map) do
    # Split charlist at every point where split_map is true
    line
    |> Enum.zip(split_map)
    |> Enum.chunk_by(fn {_, split_mark} -> split_mark end)
    |> Enum.filter(fn chunk ->
      case chunk do
        [{_, true}] -> false
        _ -> true
      end
    end)
    |> Enum.map(&Enum.map(&1, fn {char, _} -> char end))
  end

  defp apply_operation({"+", values}) do
    Enum.sum(values)
  end

  defp apply_operation({"*", values}) do
    Enum.product(values)
  end

  defp as_topdown_integers({operand, values_str}) do
    # Interpret values as columns - each column of chars represents a number
    as_integers({operand, Enum.reduce(values_str, [], &to_columns/2)})
  end

  defp as_integers({operand, values_str}) do
    # Interpret values as normal integers
    values =
      values_str
      |> Enum.map(fn v ->
        v
        |> List.to_string()
        |> String.trim()
        |> String.to_integer()
      end)

    {operand, values}
  end

  defp as_operation([operand | values_str]) do
    # Separate operand from values
    {String.trim(List.to_string(operand)), values_str}
  end

  defp to_columns([value | line_rest], [list | acc_rest]) do
    [[value | list] | to_columns(line_rest, acc_rest)]
  end

  defp to_columns([value | line_rest], []) do
    [[value] | to_columns(line_rest, [])]
  end

  defp to_columns([], acc_rest) do
    acc_rest
  end

  import AoC2025.Runner
  defrunner(Part1, id: "day06", name: "Day 6 - Part 1", do: part1)
  defrunner(Part2, id: "day06", name: "Day 6 - Part 2", do: part2)
end
