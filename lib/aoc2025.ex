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
      AoC2025.Puzzle.Day3.Part2,
      AoC2025.Puzzle.Day4.Part1,
      AoC2025.Puzzle.Day4.Part2,
      AoC2025.Puzzle.Day4Memo.Part1,
      AoC2025.Puzzle.Day4Memo.Part2
    ]
  end

  def runAll do
    all_puzzles()
    |> Enum.map(&{&1, run(&1)})
    |> Enum.each(fn {puzzle, results} ->
      IO.puts(IO.ANSI.bright() <> "--- #{puzzle.name()} ---" <> IO.ANSI.reset())

      results
      |> Enum.each(fn {path, task} ->
        IO.write("#{path}: ")
        {time_us, result} = Task.await(task, 50_000)
        IO.write(IO.ANSI.bright() <> inspect(result) <> IO.ANSI.reset())
        IO.write(" in ")
        IO.puts(AoC2025.Common.pretty_time(time_us))
      end)

      IO.puts("")
    end)
  end

  def run(puzzle) do
    AoC2025.Common.inputsFor(puzzle)
    |> Enum.sort()
    |> Enum.map(&{&1, Task.async(AoC2025, :solve, [puzzle, &1])})
  end

  def solve(puzzle, path) do
    :timer.tc(fn ->
      puzzle.solve(File.stream!(path))
    end)
  end

  def main(_args) do
    runAll()
  end
end
