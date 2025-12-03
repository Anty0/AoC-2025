defmodule AoC2025.Puzzle.Day2 do
  def part1(input) do
    for range <- parseRanges(input),
        number <- range,
        numStr = Integer.to_string(number),
        len = String.length(numStr),
        Integer.mod(len, 2) == 0,
        half = div(len, 2),
        {left, right} = String.split_at(numStr, half),
        left == right do
      number
    end
    |> Enum.sum()
  end

  def part2(input) do
    for range <- parseRanges(input),
        number <- range,
        numStr = Integer.to_charlist(number),
        len = length(numStr),
        len > 1,
        half = div(len, 2),
        step <- 1..half,
        Integer.mod(len, step) == 0,
        [first | rest] = Enum.chunk_every(numStr, step),
        Enum.all?(rest, &(first == &1)) do
      # IO.inspect({numStr, number, len, half, step, first, rest})
      number
    end
    |> Enum.uniq()
    |> Enum.sum()
  end

  defp parseRanges(input) do
    for line <- input,
        range <- String.split(String.trim(line), ","),
        [from, to] = String.split(range, "-", parts: 2) do
      from = String.to_integer(from)
      to = String.to_integer(to)
      from..to
    end
  end

  import AoC2025.Runner
  defrunner(Part1, id: "day2", name: "Day 2 - Part 1", do: part1)
  defrunner(Part2, id: "day2", name: "Day 2 - Part 2", do: part2)
end
