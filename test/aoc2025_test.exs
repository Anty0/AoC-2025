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
runnertest(AoC2025.Puzzle.Day5Sorted.Part2, example: 14, orig: 350_939_902_751_909)

runnertest(AoC2025.Puzzle.Day6.Part1, example: 4_277_556, orig: 4_309_240_495_780)
runnertest(AoC2025.Puzzle.Day6.Part2, example: 3_263_827, orig: 9_170_286_552_289)

runnertest(AoC2025.Puzzle.Day7.Part1, example: 21, orig: 1_539)
runnertest(AoC2025.Puzzle.Day7.Part2, example: 40, orig: 6_479_180_385_864)

runnertest(AoC2025.Puzzle.Day8.Part1x10, example: 40)
runnertest(AoC2025.Puzzle.Day8.Part1x1000, orig: 80446)
runnertest(AoC2025.Puzzle.Day8.Part2, "10x.example": 25272, "1000x.orig": 51_294_528)

runnertest(AoC2025.Puzzle.Day9.Part1, example: 50, orig: 4_759_420_470)
runnertest(AoC2025.Puzzle.Day9.Part2, example: 24, orig: 1_603_439_684)
