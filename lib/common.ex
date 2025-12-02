defmodule AoC2025.Common do
  def inputsFor(puzzle) do
    File.ls!(AoC2025.Constants.input_dir())
    |> Enum.filter(fn x -> String.ends_with?(x, ".txt") end)
    |> Enum.filter(fn x -> String.starts_with?(x, puzzle.id()) end)
    |> Enum.map(&Path.join(AoC2025.Constants.input_dir(), &1))
  end
end
