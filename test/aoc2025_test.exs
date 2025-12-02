defmodule AoC2025Test do
  use ExUnit.Case, async: true
  doctest AoC2025
  alias AoC2025.Puzzle, as: P

  test "day1part1" do
    assert P.Day1.part1(f("day1")) == 3
  end

  test "day1part2" do
    assert P.Day1.part2(f("day1")) == 6
  end

  def f(name) do
    path = Path.join(AoC2025.Constants.input_dir(), "#{name}.example.txt")
    File.stream!(path)
  end
end
