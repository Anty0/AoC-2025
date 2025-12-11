defmodule AoC2025.Puzzle.Day3 do
  def part1(input) do
    sumOfBestNumbers(input, 2)
  end

  def part2(input) do
    sumOfBestNumbers(input, 12)
  end

  def sumOfBestNumbers(input, len) do
    input
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&bestNumber(&1, len))
    |> Enum.map(&List.to_integer/1)
    |> Enum.sum()
  end

  defp bestNumber(_, 0) do
    []
  end

  defp bestNumber(line, len) do
    {num, startIndex} =
      line
      |> Enum.drop(-len + 1)
      |> bestDigit()

    remainingLine = Enum.drop(line, startIndex + 1)
    rest = bestNumber(remainingLine, len - 1)

    [num | rest]
  end

  defp bestDigit(list) do
    list
    |> Enum.with_index()
    |> Enum.reduce({?0, 0}, fn {item, i}, {best_item, best_index} ->
      if item > best_item do
        {item, i}
      else
        {best_item, best_index}
      end
    end)
  end

  import AoC2025.Runner
  defrunner(Part1, id: "day03", name: "Day 3 - Part 1", do: part1)
  defrunner(Part2, id: "day03", name: "Day 3 - Part 2", do: part2)
end
