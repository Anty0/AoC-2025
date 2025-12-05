import AoC2025.Runner

defmodule AoC2025Test do
  use ExUnit.Case, async: true
  doctest AoC2025
end

runnertest(AoC2025.Puzzle.Day1.Part1, example: 3, orig: 1180)
runnertest(AoC2025.Puzzle.Day1.Part2, example: 6, orig: 6892)

runnertest(AoC2025.Puzzle.Day2.Part1, example: 1_227_775_554, orig: 12_850_231_731)
runnertest(AoC2025.Puzzle.Day2.Part2, example: 4_174_379_265, orig: 24_774_350_322)

runnertest(AoC2025.Puzzle.Day3.Part1, example: 357, orig: 17_034)
runnertest(AoC2025.Puzzle.Day3.Part2, example: 3_121_910_778_619, orig: 168_798_209_663_590)

runnertest(AoC2025.Puzzle.Day4.Part1, example: 13, orig: 1_370)
runnertest(AoC2025.Puzzle.Day4.Part2, example: 43, orig: 8_437)
runnertest(AoC2025.Puzzle.Day4Memo.Part1, example: 13, orig: 1_370)
runnertest(AoC2025.Puzzle.Day4Memo.Part2, example: 43, orig: 8_437)
runnertest(AoC2025.Puzzle.Day4MemoV2.Part1, example: 13, orig: 1_370)
runnertest(AoC2025.Puzzle.Day4MemoV2.Part2, example: 43, orig: 8_437)

runnertest(AoC2025.Puzzle.Day5.Part1, example: 3, orig: 511)
runnertest(AoC2025.Puzzle.Day5.Part2, example: 14, orig: 350_939_902_751_909)
