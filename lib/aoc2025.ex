defmodule AoC2025 do
  def all_puzzles do
    [
      AoC2025.Puzzle.Day1Bad.Part1,
      AoC2025.Puzzle.Day1Bad.Part2,
      AoC2025.Puzzle.Day1.Part1,
      AoC2025.Puzzle.Day1.Part2,
      AoC2025.Puzzle.Day2.Part1,
      AoC2025.Puzzle.Day2.Part2
    ]
  end

  def runAll do
    all_puzzles()
    |> Stream.map(&run/1)
    |> Enum.each(fn {puzzle, results} ->
      IO.puts("#{puzzle.name()}:")

      results
      |> Enum.each(fn {path, result} ->
        IO.write("#{path}: ")
        IO.inspect(result)
      end)

      IO.puts("")
    end)
  end

  def run(puzzle) do
    results =
      AoC2025.Common.inputsFor(puzzle)
      |> Stream.map(fn path -> {path, puzzle.solve(File.stream!(path))} end)

    {puzzle, results}
  end
end
