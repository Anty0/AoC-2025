# This implementation of Day1 stands as a testament on how badly one can implement something as simple as Day1 puzzle.
# This code attacks the position of worse pieces of code I've seen in a long while :3

defmodule AoC2025.Puzzle.Day1Bad do
  # def doTheThing() do
  #   {:ok, contents} = File.read("day1.example.txt")
  #   r1 = part1(contents)
  #   r2 = part2(contents)
  #   {:ok, contents} = File.read("day1.orig.txt")
  #   r11 = part1(contents)
  #   r22 = part2(contents)
  #   {r1, r11, r2, r22}
  # end

  def part1(input) do
    lines = String.split(input, "\n")
    sumLines(50, lines)
  end

  def part2(input) do
    lines = String.split(input, "\n")
    sumLines2(50, lines)
  end

  def sumLines(n, [<<_>> <> "0" | tail]) do
    sumLines(n, tail)
  end

  def sumLines(n, [<<"L">> <> num | tail]) do
    num = n - String.to_integer(num)
    num = Integer.mod(num + 1, 100) - 1
    {sum, c} = sumLines(num, tail)

    c =
      if num == 0 do
        c + 1
      else
        c
      end

    # IO.inspect({num, c})
    {sum, c}
  end

  def sumLines(n, [<<"R">> <> num | tail]) do
    num = n + String.to_integer(num)
    num = Integer.mod(num + 1, 100) - 1
    {sum, c} = sumLines(num, tail)

    c =
      if num == 0 do
        c + 1
      else
        c
      end

    # IO.inspect({num, c})
    {sum, c}
  end

  def sumLines(n, [""]) do
    {n, 0}
  end

  def sumLines(n, []) do
    {n, 0}
  end

  def sumLines2(n, [<<_>> <> "0" | tail]) do
    # IO.inspect("NEXT")
    sumLines2(n, tail)
  end

  def sumLines2(n, [<<"L">> <> num | tail]) do
    num = String.to_integer(num) - 1
    n = n - 1
    # IO.inspect(num)
    n = Integer.mod(n + 1, 100) - 1
    {sum, c} = sumLines2(n, ["L" <> Integer.to_string(num) | tail])

    c =
      if n == 0 do
        c + 1
      else
        c
      end

    # IO.inspect({num, c})
    {sum, c}
  end

  def sumLines2(n, [<<"R">> <> num | tail]) do
    num = String.to_integer(num) - 1
    n = n + 1
    n = Integer.mod(n + 1, 100) - 1
    # IO.inspect(num)
    {sum, c} = sumLines2(n, ["R" <> Integer.to_string(num) | tail])

    c =
      if n == 0 do
        c + 1
      else
        c
      end

    # IO.inspect({num, c})
    {sum, c}
  end

  def sumLines2(n, [""]) do
    {n, 0}
  end

  def sumLines2(n, []) do
    {n, 0}
  end

  defmodule Part1 do
    def id, do: "day1"
    def name, do: "Day 1 (bad version): Part 1"

    def solve(input) do
      AoC2025.Puzzle.Day1Bad.part1(Enum.join(input))
    end
  end

  defmodule Part2 do
    def id, do: "day1"
    def name, do: "Day 1 (bad version): Part 2"

    def solve(input) do
      AoC2025.Puzzle.Day1Bad.part2(Enum.join(input))
    end
  end
end
