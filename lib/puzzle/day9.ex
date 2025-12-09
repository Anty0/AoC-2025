defmodule AoC2025.Puzzle.Day9 do
  def part1(input) do
    {area, _, _} =
      input
      |> parse_input()
      |> build_rectangles()
      |> Enum.sort_by(fn {area, _, _} -> area end, :desc)
      |> Enum.at(0)

    area
  end

  def part2(input) do
    # This one was fun /s

    points = parse_input(input)
    limits = find_limits(points)

    areas =
      Enum.zip(points, rotate_by_one(points))
      |> Enum.map(fn {p1, p2} -> make_area(p1, p2) end)

    # We start assuming everything is outside
    initial_areas = {[], [limits]}
    # Then we mark the path itself as inside
    {_inside_areas, outside_areas} = split_areas(areas, initial_areas)
    # And then we flood fill the outside areas to confirm they are really outside - rest is inside
    {_kinda_inside, fully_outside} = confirm_outside_areas(outside_areas, [], limits)

    # inside_areas  -> Areas confirmed to be inside the area carved by path
    # outside_areas -> All other areas not visited by the path
    # kinda_inside  -> Areas confirmed to be inside by flood fill (flood fill didn't reach them)
    # fully_outside -> Areas confirmed to be outside by flood fill (flood fill reached them)

    {area, _, _} =
      points
      |> build_rectangles()
      |> Enum.sort_by(fn {area, _, _} -> area end, :desc)
      |> Stream.filter(fn {_, p1, p2} ->
        # Only areas that are fully inside - no overlap with outside areas
        not any_overlap?(make_area(p1, p2), fully_outside)
      end)
      |> Enum.at(0)

    area
  end

  defp confirm_outside_areas(remaining, confirmed, limits) do
    {new_confirmed, remaining} =
      Enum.split_with(remaining, &confirm_outside_area(&1, confirmed, limits))

    case new_confirmed do
      [] -> {remaining, confirmed}
      _ -> confirm_outside_areas(remaining, new_confirmed ++ confirmed, limits)
    end
  end

  defp confirm_outside_area({sx, sy, ex, ey}, confirmed_outside, {min_x, min_y, max_x, max_y}) do
    # Checks if area is touching the edge of the grid. If not, performs single "flood fill" step using `confirmed_outside` areas as a reference.
    # Returns true if area is touching the edge of the grid or any of the areas in `confirmed_outside`.
    cond do
      sx <= min_x or sy <= min_y or ex >= max_x or ey >= max_y ->
        # Area is touching the edge - automatically counts as outside area
        true

      Enum.any?(confirmed_outside, fn {csx, csy, cex, cey} ->
        # If they share a side, then this area is also outside
        cond do
          (sx == cex + 1 or ex == csx - 1) and
                ((csy >= sy and cey <= ey) or (csy < sy and cey >= sy) or (cey > ey and csy <= ey)) ->
            # Sharing top/bottom side
            true

          (sy == cey + 1 or ey == csy - 1) and
                ((csx >= sx and cex <= ex) or (csx < sx and cex >= sx) or (cex > ex and csx <= ex)) ->
            # Sharing left/right side
            true

          true ->
            # No shared side
            false
        end
      end) ->
        true

      true ->
        false
    end
  end

  defp split_areas([current | rest], {inside_areas, outside_areas}) do
    # Takes a list of areas that define what is "inside" and state which contains a list of inside areas and outside areas
    # The state should be initialized with a single outside area covering a whole area of operations.
    # (Any non-ovelaping sections with any of the areas in state are ignored.)
    # The function takes areas form the first list one by one and takes care of splitting and arranging areas in the state such that:
    # - No area in the state will overlap with any other area in the state (even if input areas overlap)
    # - Areas inside `inside_areas` are strictly inside at leas one of input areas in the first list
    # - Areas in the `outside_areas` are not overlapping with any of the areas in the first input list
    {inside1, inside2} = split_areas(current, inside_areas)
    {inside3, outside} = split_areas(current, outside_areas)
    areas = {inside1 ++ inside2 ++ inside3, outside}
    split_areas(rest, areas)
  end

  defp split_areas([], areas) do
    areas
  end

  defp split_areas(area, [current | rest]) do
    # Splits all areas in the list such that each area is either strictly inside the specified area or outside the specified area.
    # Returns two lists of areas - one with areas that are inside the specified area and one with areas that are outside the specified area.
    {inside_rest, outside_rest} = split_areas(area, rest)
    {inside, outside} = split_area(area, current)
    {inside ++ inside_rest, outside ++ outside_rest}
  end

  defp split_areas(_, []) do
    {[], []}
  end

  defp split_area({sx, sy, ex, ey}, {asx, asy, aex, aey} = outside) do
    # Returns two lists of rectangles - one with rectangles that are inside
    # of the first area and one with rectangles that are outside of the first area.
    # The first rectangle defines boundaries of the "inside" area.
    # The second rectangle defines boundaries of the "outside" area and boundaries of the resulting areas.

    # Crop first area to fit the boundaries specified by the second area.
    csx = max(sx, asx)
    csy = max(sy, asy)
    cex = min(ex, aex)
    cey = min(ey, aey)

    if csx > cex or csy > cey do
      # No changes if areas don't overlap
      {[], [outside]}
    else
      # Now we split the area into into 9 parts:
      # - Inner part
      # - Top left corner
      # - Above
      # - Top right
      # - Right
      # - Bottom right
      # - Below
      # - Bottom left
      # - Left

      inner = {csx, csy, cex, cey}
      top_left = {asx, asy, csx - 1, csy - 1}
      above = {csx, asy, cex, csy - 1}
      top_right = {cex + 1, asy, aex, csy - 1}
      right = {cex + 1, csy, aex, cey}
      bottom_right = {cex + 1, cey + 1, aex, aey}
      below = {csx, cey + 1, cex, aey}
      bottom_left = {asx, cey + 1, csx - 1, aey}
      left = {asx, csy, csx - 1, cey}

      # But only keep areas that actually contain something
      outside_areas =
        [top_left, above, top_right, right, bottom_right, below, bottom_left, left]
        |> Enum.filter(&(not empty?(&1)))

      {[inner], outside_areas}
    end
  end

  defp any_overlap?(area, areas) do
    # Returns true if any of the areas overlap with the given area.
    Enum.any?(areas, fn other -> overlap?(area, other) end)
  end

  defp overlap?({sx1, sy1, ex1, ey1}, {sx2, sy2, ex2, ey2}) do
    # Returns true if two areas overlap
    not (sx1 > ex2 or sx2 > ex1 or sy1 > ey2 or sy2 > ey1)
  end

  defp empty?({sx, sy, ex, ey}) do
    # Basically filters out invalid areas - areas with negative width or height
    sx > ex or sy > ey
  end

  defp make_area({x1, y1}, {x2, y2}) do
    # {sx, sy, ex, ey} where sx <= ex and sy <= ey
    # Makes math easier
    {min(x1, x2), min(y1, y2), max(x1, x2), max(y1, y2)}
  end

  defp rotate_by_one([first | rest]) do
    # Moves first item in the list to the end of the list.
    rest ++ [first]
  end

  defp find_limits([{x, y}]) do
    {x - 1, y - 1, x + 1, y + 1}
  end

  defp find_limits([{x, y} | rest]) do
    # Returns boundaries of the rectangle that contains all points in the list.
    # Note: We make the boundary one point bigger than the actual rectangle.
    # This is mostly for visual purposes when debugging, but also has the added benefit of making
    # it possible to check for any rectangle that has at least one edge inside of the grid.
    # Shouldn't be necessary for the solution itself to work.
    {min_x, min_y, max_x, max_y} = find_limits(rest)
    {min(x - 1, min_x), min(y - 1, min_y), max(x + 1, max_x), max(y + 1, max_y)}
  end

  defp build_rectangles([current | rest]) do
    # Returns list of rectangles between all points in the list.
    build_rectangles(current, rest) ++ build_rectangles(rest)
  end

  defp build_rectangles([]) do
    []
  end

  defp build_rectangles({fx, fy} = from, [{tx, ty} = to | rest]) do
    # Returns list of rectangles with one corner at `from` and other in all other points in the list.
    area = (abs(fx - tx) + 1) * (abs(fy - ty) + 1)
    [{area, from, to} | build_rectangles(from, rest)]
  end

  defp build_rectangles(_, []) do
    []
  end

  defp parse_input(input) do
    Enum.map(input, &parse_line/1)
  end

  defp parse_line(line) do
    # Spits line into two integers: coordinates
    [x, y] =
      line
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    {x, y}
  end

  def draw_areas({inside_areas, outside_areas}, {min_x, min_y, max_x, max_y}) do
    # For debugging purposes
    # This code ain't really readable and I'm not fixing that.
    # Prints out 2D grid showing edges of all areas, diferentiating between first and second list.
    # And then second 2D grid masking areas that are in the first list vs areas that are in the second list.

    IO.write("\n ")

    Enum.each(min_x..max_x, fn x ->
      IO.write(String.at(Integer.to_string(x), -1))
    end)

    IO.write("\n")

    Enum.each(min_y..max_y, fn y ->
      IO.write(String.at(Integer.to_string(y), -1))

      Enum.each(min_x..max_x, fn x ->
        cond do
          # Capitalized edges of inside areas
          Enum.any?(inside_areas, fn {sx, sy, _, _} -> sx == x and sy == y end) ->
            "S"

          Enum.any?(inside_areas, fn {_, _, ex, ey} -> ex == x and ey == y end) ->
            "E"

          Enum.any?(inside_areas, fn {sx, _, _, ey} -> sx == x and ey == y end) ->
            "L"

          Enum.any?(inside_areas, fn {_, sy, ex, _} -> ex == x and sy == y end) ->
            "R"

          # Lowercase edges of outside areas
          Enum.any?(outside_areas, fn {sx, sy, _, _} -> sx == x and sy == y end) ->
            "s"

          Enum.any?(outside_areas, fn {_, _, ex, ey} -> ex == x and ey == y end) ->
            "e"

          Enum.any?(outside_areas, fn {sx, _, _, ey} -> sx == x and ey == y end) ->
            "l"

          Enum.any?(outside_areas, fn {_, sy, ex, _} -> ex == x and sy == y end) ->
            "r"

          # Walls
          Enum.any?(inside_areas, fn {sx, sy, ex, ey} ->
            (sx == x or ex == x) and y >= sy and y <= ey
          end) ->
            "|"

          Enum.any?(inside_areas, fn {sx, sy, ex, ey} ->
            (sy == y or ey == y) and x >= sx and x <= ex
          end) ->
            "-"

          Enum.any?(outside_areas, fn {sx, sy, ex, ey} ->
            (sx == x or ex == x) and y >= sy and y <= ey
          end) ->
            "I"

          Enum.any?(outside_areas, fn {sx, sy, ex, ey} ->
            (sy == y or ey == y) and x >= sx and x <= ex
          end) ->
            "~"

          true ->
            " "
        end
        |> IO.write()
      end)

      IO.write("\n")
    end)

    IO.write("\n ")

    Enum.each(min_x..max_x, fn x ->
      IO.write(String.at(Integer.to_string(x), -1))
    end)

    IO.write("\n")

    Enum.each(min_y..max_y, fn y ->
      IO.write(String.at(Integer.to_string(y), -1))

      Enum.each(min_x..max_x, fn x ->
        cond do
          Enum.any?(inside_areas, fn {sx, sy, ex, ey} ->
            x >= sx and x <= ex and y >= sy and y <= ey
          end) ->
            "X"

          Enum.any?(outside_areas, fn {sx, sy, ex, ey} ->
            x >= sx and x <= ex and y >= sy and y <= ey
          end) ->
            "."

          true ->
            " "
        end
        |> IO.write()
      end)

      IO.write("\n")
    end)
  end

  import AoC2025.Runner
  defrunner(Part1, id: "day9", name: "Day 9 - Part 1", do: part1)
  defrunner(Part2, id: "day9", name: "Day 9 - Part 2", do: part2)
end
