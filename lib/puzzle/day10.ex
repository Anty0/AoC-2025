defmodule AoC2025.Puzzle.Day10.Machine do
  defstruct lights: nil,
            lights_length: nil,
            lights_buttons: [],
            joltages_buttons: [],
            joltages: nil

  @typedoc "A representation of Machine for Day10 puzzle"
  @type t() :: %__MODULE__{
          lights: non_neg_integer() | nil,
          lights_length: non_neg_integer() | nil,
          lights_buttons: [non_neg_integer()],
          joltages_buttons: [[non_neg_integer()]],
          joltages: [non_neg_integer()] | nil
        }
end

defmodule AoC2025.Puzzle.Day10 do
  import Bitwise

  require Dantzig.Problem, as: Problem
  require Dantzig.Constraint, as: Constraint

  alias AoC2025.Common
  alias AoC2025.Puzzle.Day10.Machine

  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&solve_machine_lights/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(&Task.async(fn -> solve_machine_joltages(&1) end))
    |> Task.await_many()
    |> Enum.sum()
  end

  defp solve_machine_joltages(machine) do
    joltages_range = 0..(tuple_size(machine.joltages) - 1)

    # Prepare matrix
    a =
      machine.joltages_buttons
      |> Enum.map(fn button ->
        # Each row is a button, each column is 1 if button
        # incrises the joltage on that index, otherwise 0
        joltages_range
        |> Enum.map(fn index -> if Enum.member?(button, index), do: 1, else: 0 end)
      end)
      # And then we flip rows and columns to get proper matrix
      |> MatrixOperation.transpose()

    b_flat = Tuple.to_list(machine.joltages)

    # Time to pull out HiGHS Solver
    problem = Problem.new(direction: :minimize)

    # Prepare stuff that needs normal math
    var_cnt = length(hd(a))
    var_range = 0..(var_cnt - 1)

    # From this point onwards normal oprators like:
    # + - * /
    # Won't work as expected - instead they generate polynomials
    use Dantzig.Polynomial.Operators

    # Variables
    {problem, variables} =
      Enum.reduce(var_range, {problem, []}, fn i, {prob, vars} ->
        var_name = String.to_atom("x#{i}")
        {prob, var} = Problem.new_variable(prob, var_name, min: 0, type: :integer)
        {prob, [var | vars]}
      end)

    variables = Enum.reverse(variables)

    # Constraints
    problem =
      Enum.zip(a, b_flat)
      |> Enum.reduce(problem, fn {row, b_value}, prob ->
        expr =
          Enum.zip(row, variables)
          |> Enum.reduce(0, fn {coef, var}, acc ->
            if coef == 0, do: acc, else: acc + coef * var
          end)

        constraint = Constraint.new(expr == b_value)
        Problem.add_constraint(prob, constraint)
      end)

    # Objective
    sum_expr = Enum.reduce(variables, 0, fn var, acc -> acc + var end)
    problem = Problem.increment_objective(problem, sum_expr)

    # Solve
    solution = AoC2025.Dantzig.HiGS.solve(problem)

    # Since our objective is measured as sum of all variables, we can use it directly
    solution.objective
  end

  defp solve_machine_lights(machine) do
    # Iterative DFS search of shortest combinations
    Common.index()
    |> Stream.map(fn limit ->
      {
        limit,
        has_valid_lights_setup_combination(
          machine.lights_buttons,
          initial_lights(machine),
          machine.lights,
          limit
        )
      }
    end)
    |> Stream.filter(fn {_limit, valid?} -> valid? end)
    |> Stream.map(fn {limit, _valid?} -> limit end)
    |> Enum.at(0)
  end

  defp has_valid_lights_setup_combination(_, current_lights, target_lights, 0) do
    # We reached the limit, check if we have the right combination of lights
    target_lights == current_lights
  end

  defp has_valid_lights_setup_combination([], _, _, _) do
    # Not enough buttons left
    false
  end

  defp has_valid_lights_setup_combination(buttons, current_lights, target_lights, limit) do
    # Try to toggle the button if button isn't part of the combination, skip it and continue with next one
    [button | rest] = buttons
    updated_lights = bxor(current_lights, button)

    cond do
      has_valid_lights_setup_combination(rest, updated_lights, target_lights, limit - 1) ->
        true

      has_valid_lights_setup_combination(rest, current_lights, target_lights, limit) ->
        true

      true ->
        false
    end
  end

  defp parse_input(input) do
    input |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split(" ")
    |> parse_machine(%Machine{})
  end

  defp parse_machine(["[" <> section | rest], %Machine{} = machine) do
    # Lights
    section = section |> String.trim_trailing("]")
    {lights_length, lights} = parse_lights(section)
    parse_machine(rest, %{machine | lights: lights, lights_length: lights_length})
  end

  defp parse_machine(["(" <> section | rest], machine) do
    # Button
    section = section |> String.trim_trailing(")")

    %Machine{lights_buttons: lb, joltages_buttons: jb} = machine

    parse_machine(rest, %{
      machine
      | lights_buttons: [parse_indices_button(section) | lb],
        joltages_buttons: [parse_indexed_button(section) | jb]
    })
  end

  defp parse_machine(["{" <> section | rest], %Machine{} = machine) do
    # Joltages
    section = section |> String.trim_trailing("}")
    parse_machine(rest, %{machine | joltages: parse_joltages(section)})
  end

  defp parse_machine([], %Machine{joltages_buttons: joltages_buttons} = machine) do
    sorted_joltages_buttons =
      Enum.sort_by(joltages_buttons, fn buttons -> length(buttons) end, :desc)

    machine = %{machine | joltages_buttons: sorted_joltages_buttons}
    validate_machine(machine)
  end

  defp parse_joltages(section) do
    section
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp parse_indices_button(section) do
    section
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> indices_to_number()
  end

  defp parse_indexed_button(section) do
    section
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.sort()
  end

  defp parse_lights(section) do
    lights =
      section
      |> String.to_charlist()
      |> Enum.map(&parse_lightstate/1)

    # |> List.to_tuple()
    {length(lights), bitmap_to_number(lights)}
  end

  defp parse_lightstate(?#), do: true
  defp parse_lightstate(?.), do: false

  defp validate_machine(
         %AoC2025.Puzzle.Day10.Machine{
           lights: lights,
           lights_length: lights_length,
           lights_buttons: lights_buttons,
           joltages_buttons: joltages_buttons,
           joltages: joltages
         } = machine
       ) do
    if lights_length == nil do
      raise "Lights length not found"
    end

    max_lights = 0..(lights_length - 1) |> Enum.map(fn _ -> true end) |> bitmap_to_number()

    cond do
      lights == nil ->
        raise "Lights not found"

      lights_buttons == [] ->
        raise "Lights buttons not found"

      joltages_buttons == [] ->
        raise "Joltages buttons not found"

      joltages == nil ->
        raise "Joltages not found"

      Enum.any?(lights_buttons, fn lights_bitmap ->
        lights_bitmap > max_lights or lights_bitmap < 0
      end) ->
        raise "Lights button contains invalid light ID"

      Enum.any?(
        joltages_buttons,
        &Enum.any?(&1, fn joltage_index ->
          joltage_index >= tuple_size(joltages) or joltage_index < 0
        end)
      ) ->
        raise "Joltages button contains invalid joltage index"

      lights_length != tuple_size(joltages) ->
        raise "Lights and joltages must have the same length"

      true ->
        machine
    end
  end

  defp bitmap_to_number([true | rest]) do
    bitmap_to_number(rest) <<< 1 ||| 1
  end

  defp bitmap_to_number([false | rest]) do
    bitmap_to_number(rest) <<< 1
  end

  defp bitmap_to_number([]) do
    0
  end

  defp indices_to_number([index | rest]) do
    indices_to_number(rest) ||| 1 <<< index
  end

  defp indices_to_number([]) do
    0
  end

  defp initial_lights(%Machine{lights: _lights}) do
    0
  end

  import AoC2025.Runner
  defrunner(Part1, id: "day10", name: "Day 10 - Part 1", do: part1)
  defrunner(Part2, id: "day10", name: "Day 10 - Part 2", do: part2)
end
