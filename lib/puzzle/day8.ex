defmodule AoC2025.Puzzle.Day8 do
  def part1x10(input) do
    part1(input, 10)
  end

  def part1x1000(input) do
    part1(input, 1000)
  end

  def part1(input, n) do
    # find 3 largest groups of connected boxes and multiply their sizes
    {connection_map, initial_state} = prepare(input)
    {{_, groups, _}, _} = state(initial_state, connection_map, n)

    groups
    |> Enum.map(&Enum.count/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  def part2(input) do
    # find last connection and multiply x coordinates of its endpoints
    {connection_map, initial_state} = prepare(input)
    {{_, _, {last_from, last_to}}, _} = state(initial_state, connection_map, -1)
    {last_from_x, _, _} = last_from
    {last_to_x, _, _} = last_to
    last_from_x * last_to_x
  end

  defp prepare(input) do
    # Prepare connection map and initial state from input
    # Connection map is sorted by distance, so that we can find closest connections first.
    boxes = parse_input(input)

    connection_map =
      build_connection_map(boxes)
      |> Enum.sort_by(fn {distance, _, _} -> distance end)

    # state: {unconnected boxes, connected groups, last connection}
    initial_state = {boxes, [], nil}

    {connection_map, initial_state}
  end

  defp build_connection_map([current | rest]) do
    # Returns list of connections between all boxes in the list.
    build_connection_map(current, rest) ++ build_connection_map(rest)
  end

  defp build_connection_map([]) do
    []
  end

  defp build_connection_map({fx, fy, fz} = from, [{tx, ty, tz} = to | rest]) do
    # Returns list of connections starting from `from` box and ending in all other boxes in the list.
    distance = :math.sqrt(abs(fx - tx) ** 2 + abs(fy - ty) ** 2 + abs(fz - tz) ** 2)
    [{distance, from, to} | build_connection_map(from, rest)]
  end

  defp build_connection_map(_, []) do
    []
  end

  defp state(state, _, 0) do
    # Hit the limit of connections - return state
    {state, 0}
  end

  defp state({[], _, _} = state, _, limit) do
    # No more boxes to connect - return state and current limit
    {state, limit}
  end

  defp state({unconnected, connected_groups, _}, [{_, from, to} | connection_map_rest], limit) do
    if Enum.any?(connected_groups, fn group ->
         Enum.member?(group, from) and Enum.member?(group, to)
       end) do
      # Already connected - try next connection
      state({unconnected, connected_groups, {from, to}}, connection_map_rest, limit - 1)
    else
      {connected_groups, from_group} = pop_with(connected_groups, &Enum.member?(&1, from))
      {connected_groups, to_group} = pop_with(connected_groups, &Enum.member?(&1, to))

      case {from_group, to_group} do
        {nil, nil} ->
          # Both unconnected - new group
          state(
            {unconnected -- [from, to], [[from, to] | connected_groups], {from, to}},
            connection_map_rest,
            limit - 1
          )

        {nil, group} ->
          # One of the boxes unconnected
          state(
            {unconnected -- [from], [[from | group] | connected_groups], {from, to}},
            connection_map_rest,
            limit - 1
          )

        {group, nil} ->
          # One of the boxes unconnected
          state(
            {unconnected -- [to], [[to | group] | connected_groups], {from, to}},
            connection_map_rest,
            limit - 1
          )

        {group1, group2} ->
          # Each box in different group - merge them
          state(
            {unconnected, [group1 ++ group2 | connected_groups], {from, to}},
            connection_map_rest,
            limit - 1
          )
      end
    end
  end

  defp pop_with(enumerable, predicate) do
    # Pops item out of list. Predicate must find select one or zero items to pull out of the enumerable.
    # (Since for pulling out multiple items `Enum.split_with` already works fine.)
    {found, enumerable} = Enum.split_with(enumerable, predicate)

    item =
      case found do
        [item] -> item
        [] -> nil
      end

    {enumerable, item}
  end

  defp parse_input(input) do
    input
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    # Split line into list of integers representing coordinates of each box.
    line
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  import AoC2025.Runner
  defrunner(Part1x10, id: "day8.10x", name: "Day 8 - Part 1 (depth 10)", do: part1x10)
  defrunner(Part1x1000, id: "day8.1000x", name: "Day 8 - Part 1 (depth 1000)", do: part1x1000)
  defrunner(Part2, id: "day8", name: "Day 8 - Part 2", do: part2)
end
