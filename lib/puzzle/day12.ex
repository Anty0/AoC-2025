defmodule AoC2025.Puzzle.Day12.Present do
  @type t :: %__MODULE__{
          id: non_neg_integer(),
          occupancy_map: [[boolean]],
          size: non_neg_integer()
        }
  defstruct [:id, :occupancy_map, :size]
end

defmodule AoC2025.Puzzle.Day12.Space do
  @type t :: %__MODULE__{
          width: non_neg_integer(),
          height: non_neg_integer(),
          requirements: [non_neg_integer()]
        }
  defstruct [:width, :height, :requirements]
end

defmodule AoC2025.Puzzle.Day12 do
  alias AoC2025.Common
  alias AoC2025.Puzzle.Day12.{Present, Space}

  # Lets hardcode present size to make our life easir
  @present_grid_size 3

  def part1(input) do
    {presents, spaces} = parse_input(input)
    fit_min = Enum.count(spaces, &fits_min/1)
    fit_max = Enum.count(spaces, &fits_max(&1, presents))

    if fit_min == fit_max do
      # If all spaces both are either guaranteed to fit all presents or guaranteed to not fit some presents,
      # we know for sure the result.
      fit_min
    else
      # Othewise we would need to do more shinanigens to figure out the result, which wasn't
      # required to finish this puzzle.
      {fit_min, fit_max}
    end
  end

  defp fits_min(%Space{width: w, height: h, requirements: req}) do
    # Here we calculate if we can fulfill the requirement by putting squares next to each other - without doing any crazy shinanegens
    # If this succeeds, we know for sure presents will fit in this space

    # Crop to squares
    w = w - rem(w, @present_grid_size)
    h = h - rem(h, @present_grid_size)
    size = w * h

    available_squares = size / (@present_grid_size * @present_grid_size)
    required_squares = Enum.sum(req)

    available_squares >= required_squares
  end

  defp fits_max(%Space{width: w, height: h, requirements: req}, presents) do
    # Here we calculate how many individual points are required to fit everything
    # If this fails, we know for sure presents won't fit in this space
    available_points = w * h

    required_points =
      req
      |> Enum.zip(Common.index())
      |> Enum.map(fn {count, index} ->
        present = Enum.find(presents, fn %Present{id: id} -> id == index end)
        present.size * count
      end)
      |> Enum.sum()

    available_points >= required_points
  end

  defp parse_input(input) do
    # Returns {presents_list, spaces_list}
    input
    |> Stream.map(&String.trim/1)
    |> Stream.chunk_by(&(&1 == ""))
    |> Enum.flat_map(&parse_block/1)
    |> Enum.split_with(fn x ->
      case x do
        %Present{} -> true
        %Space{} -> false
      end
    end)
  end

  defp parse_block([]), do: []
  defp parse_block([""]), do: []

  defp parse_block([first_line | rest]) do
    [number, rest_line] = String.split(first_line, ":", parts: 2)

    if String.contains?(number, "x") do
      # Definition of space and required presents

      [width, height] = String.split(number, "x")

      [
        %Space{
          width: String.to_integer(width),
          height: String.to_integer(height),
          requirements:
            rest_line
            |> String.split(" ", trim: true)
            |> Enum.map(&String.to_integer/1)
        }
        | parse_block(rest)
      ]
    else
      # Definition of present

      # Sanity asserts
      "" = rest_line
      @present_grid_size = length(rest)
      Enum.each(rest, fn row -> @present_grid_size = String.length(row) end)

      occupancy_map =
        rest
        |> Enum.map(&String.to_charlist/1)
        |> Common.enum_map2d(&parse_occupancy_char/1)

      [
        %Present{
          id: String.to_integer(number),
          occupancy_map: occupancy_map,
          size: occupancy_map |> Enum.sum_by(&Enum.count(&1, fn x -> x end))
        }
      ]
    end
  end

  defp parse_occupancy_char(?#), do: true
  defp parse_occupancy_char(?.), do: false

  import AoC2025.Runner
  defrunner(Part1, id: "day12", name: "Day 12 - Part 1", do: part1)
end
