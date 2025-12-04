defmodule AoC2025 do
  def all_puzzles do
    [
      AoC2025.Puzzle.Day1Bad.Part1,
      AoC2025.Puzzle.Day1Bad.Part2,
      AoC2025.Puzzle.Day1.Part1,
      AoC2025.Puzzle.Day1.Part2,
      AoC2025.Puzzle.Day2.Part1,
      AoC2025.Puzzle.Day2.Part2,
      AoC2025.Puzzle.Day3.Part1,
      AoC2025.Puzzle.Day3.Part2
    ]
  end

  def runAll do
    all_puzzles()
    |> Enum.map(&{&1, run(&1)})
    |> Enum.each(fn {puzzle, results} ->
      IO.puts("--- #{puzzle.name()} ---")

      results
      |> Enum.each(fn {path, task} ->
        IO.write("#{path}: ")
        result = Task.await(task, 50_000)
        IO.inspect(result)
      end)

      IO.puts("")
    end)
  end

  def run(puzzle) do
    AoC2025.Common.inputsFor(puzzle)
    |> Enum.map(&{&1, Task.async(AoC2025, :solve, [puzzle, &1])})
  end

  def solve(puzzle, path) do
    puzzle.solve(File.stream!(path))
  end

  def main(_args) do
    runAll()
  end
end
