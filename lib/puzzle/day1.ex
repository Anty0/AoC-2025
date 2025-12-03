defmodule AoC2025.Puzzle.Day1 do
  def part1(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parseLine/1)
    |> Stream.scan(50, &+/2)
    |> Stream.map(&normalize/1)
    |> Enum.count(&(&1 == 0))
  end

  def part2(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parseLine/1)
    |> Stream.flat_map(&splitStep/1)
    |> Stream.scan(50, &+/2)
    |> Stream.map(&normalize/1)
    |> Enum.count(&(&1 == 0))
  end

  defp parseLine(line) do
    case line do
      <<"L">> <> num -> -String.to_integer(num)
      <<"R">> <> num -> String.to_integer(num)
    end
  end

  defp splitStep(n) do
    case n do
      n when n > 0 -> List.duplicate(1, n)
      n when n < 0 -> List.duplicate(-1, -n)
      0 -> []
    end
  end

  defp normalize(n) do
    Integer.mod(n, 100)
  end

  import AoC2025.Runner
  defrunner(Part1, id: "day1", name: "Day 1 - Part 1", do: part1)
  defrunner(Part2, id: "day1", name: "Day 1 - Part 2", do: part2)
end
