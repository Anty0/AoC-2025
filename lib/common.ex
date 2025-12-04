defmodule AoC2025.Common do
  def inputsFor(puzzle) do
    File.ls!(AoC2025.Constants.input_dir())
    |> Enum.filter(fn x -> String.ends_with?(x, ".txt") end)
    |> Enum.filter(fn x -> String.starts_with?(x, puzzle.id()) end)
    |> Enum.map(&Path.join(AoC2025.Constants.input_dir(), &1))
  end

  def pretty_time(us) when is_integer(us) do
    cond do
      us < 1_000 ->
        IO.ANSI.green_background() <> IO.ANSI.black() <> " #{us} µs " <> IO.ANSI.reset()

      us < 1_000_000 ->
        IO.ANSI.yellow_background() <>
          IO.ANSI.black() <> " #{Float.round(us / 1_000, 2)} ms " <> IO.ANSI.reset()

      true ->
        IO.ANSI.red_background() <>
          IO.ANSI.white() <> " #{Float.round(us / 1_000_000, 2)} s " <> IO.ANSI.reset()
    end
  end
end
