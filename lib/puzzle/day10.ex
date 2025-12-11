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

  alias AoC2025.Puzzle.Day10.Machine

  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&lights_setup_combination_length/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse_input()
    # |> Enum.zip(Stream.iterate(0, &(&1 + 1)))
    # |> Enum.map(&joltages_setup_combination_length/1)
    |> Enum.map(&solve_machine_joltages/1)
    # |> Enum.map(&Task.async(fn -> joltages_setup_combination_length(&1) end))
    # |> Task.await_many()
    # |> Task.await_many(:infinity)
    |> Enum.sum()
  end

  defp solve_machine_joltages(machine) do
    # IO.inspect(machine.joltages)
    # IO.inspect(machine.joltages_buttons)

    a = MatrixOperation.transpose(Enum.map(machine.joltages_buttons, fn button ->
      Enum.map(0..tuple_size(machine.joltages)-1, fn index ->
        if Enum.member?(button, index) do 1 else 0 end
      end)
    end))
    b_flat = Tuple.to_list(machine.joltages)

    # IO.inspect(a)
    # IO.inspect(b_flat)

    solve_machine_joltages(a, b_flat) |> IO.inspect()
  end

  defp solve_machine_joltages(a, b_flat) do
    problem = Problem.new(direction: :minimize)

    var_cnt = length(hd(a))
    var_range = 0..(var_cnt-1)

    use Dantzig.Polynomial.Operators

    # Dynamically create variables
    {problem, variables, var_names} =
      Enum.reduce(var_range, {problem, [], []}, fn i, {prob, vars, names} ->
        var_name = String.to_atom("x#{i}")
        {prob, var} = Problem.new_variable(prob, var_name, min: 0, type: :integer)
        {prob, [var | vars], [var_name | names]}
      end)

    variables = Enum.reverse(variables)
    var_names = Enum.reverse(var_names)

    # Add constraints
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

    # Set objective
    sum_expr = Enum.reduce(variables, 0, fn var, acc -> acc + var end)
    problem = Problem.increment_objective(problem, sum_expr)

    # Solve
    solution = AoC2025.Dantzig.HiGS.solve(problem)

    # IO.inspect(solution)
    # IO.inspect(solution.model_status)
    solution.objective
  end

  #(2) (4,5) (3,5) (0,5) (1,5) (1,2,4,5) {4,135,127,8,135,155}
  #5 155x -> (1,2,4,5) or (1,5) or (0,5) or (3,5) or (4,5)
  #4 135x -> (1,2,4,5) or (4,5)
  #3   8x -> (3,5)
  #2 127x -> (1,2,4,5) or (2)
  #1 135x -> (1,2,4,5) or (1,5)
  #0   4x -> (0,5)

  #(1,2,4,5) max 127 ---
  #(1,5)     max 135
  #(0,5)     max 4
  #(3,5)     max 8
  #(4,5)     max 135
  #(2)       max 127

  #5 155-127 = 28x -> (1,2,4,5) or (1,5) or (0,5) or (3,5) or (4,5)
  #4 135-127 =  8x -> (1,2,4,5) or (4,5)
  #3 8-0     =  8x -> (3,5)
  #2 127-127 =  0x -> (1,2,4,5) or (2)
  #1 135-127 =  8x -> (1,2,4,5) or (1,5)
  #0 4-0     =  4x -> (0,5)

  #(1,2,4,5) max 0
  #(1,5)     max 8 ---
  #(0,5)     max 4
  #(3,5)     max 8
  #(4,5)     max 8
  #(2)       max 0

  #5 28-8 = 20x -> (1,2,4,5) or (1,5) or (0,5) or (3,5) or (4,5)
  #4 8-0  =  8x -> (1,2,4,5) or (4,5)
  #3 8-0  =  8x -> (3,5)
  #2 0-0  =  0x -> (1,2,4,5) or (2)
  #1 8-8  =  0x -> (1,5)
  #0 4-0  =  4x -> (0,5)

  #(1,2,4,5) max 0
  #(1,5)     max 0
  #(0,5)     max 4
  #(3,5)     max 8 ---
  #(4,5)     max 8
  #(2)       max 0

  #5 20-8 = 12x -> (1,2,4,5) or (1,5) or (0,5) or (3,5) or (4,5)
  #4 8-0  =  8x -> (1,2,4,5) or (4,5)
  #3 8-8  =  0x -> (3,5)
  #2 0-0  =  0x -> (1,2,4,5) or (2)
  #1 9-0  =  0x -> (1,2,4,5) or (1,5)
  #0 4-0  =  4x -> (0,5)

  #(1,2,4,5) max 0
  #(1,5)     max 0
  #(0,5)     max 4
  #(3,5)     max 0
  #(4,5)     max 8 ---
  #(2)       max 0


  #(0,1,2,4,5,7,8) (1,2,3,5,6,7,8,9) (0,2,4,5,6,7,9) (3,6) (0,1,9) (0,1,4) (0,2,3,4,6,8,9) (0,2,3,4,7,9) (2,4,5,9) (0,1,2,5,6,8,9) (0,2,3,5,6,7,9) {286,248,300,62,259,273,77,256,239,116}
  #1110111110
  #0111011111
  #1010111101
  #0001001000
  #1100000001
  #1100100000
  #1011101111
  #1011100101
  #1011011101




  defp joltages_setup_combination_length(machine) do
    0

    # input = JSON.encode!([moves: machine.joltages_buttons, target: machine.joltages])
    # {output, _} = System.cmd("python3", ["./lib/puzzle/day10.py", input])
    # IO.inspect(output)
    # String.to_integer(String.trim(output))



    # # IO.inspect({"START", machine})
    # tid = :ets.new(:day10_machine_store, [:set])
    # buttons = machine.joltages_buttons |> Enum.sort_by(fn button -> length(button) end, :desc)
    # result = joltages_setup_combination_length(tid, buttons, machine.joltages)
    # # IO.inspect({"END", result, machine})
    # # IO.inspect({index, result})
    # IO.puts(Integer.to_string(index) <> "," <> Integer.to_string(result))
    # :ets.delete(tid)
    # result



    # Stream.iterate(0, &(&1 + 1))
    # |> Stream.map(&IO.inspect/1)
    # |> Stream.map(fn limit -> {limit, has_valid_joltages_setup_combination(machine, initial_joltages(machine), limit)} end)
    # |> Stream.filter(fn {_limit, valid?} -> valid? end)
    # |> Stream.map(fn {limit, _valid?} -> limit end)
    # |> Enum.at(0)
  end

  defp joltages_setup_combination_length(_, [], _) do
    nil
  end

  defp joltages_setup_combination_length(tid, buttons, target_joltages) do
    # memoized(tid, {buttons, target_joltages}, fn ->
    required = target_joltages |> Tuple.to_list() |> Enum.zip(Stream.iterate(0, &(&1 + 1)))
    |> Enum.filter(fn {joltage, _index} -> joltage > 0 end)
    |> Enum.map(fn {_joltage, index} -> index end)

    has_missing_button = Enum.any?(required, fn index ->
      Enum.all?(buttons, &not(Enum.member?(&1, index)))
    end)

    has_missing_button = has_missing_button or Enum.any?(required, fn index ->
      # We find all buttons that controll this joltage
      # We sum up how many times you can press them max
      # If the sum is less then the required joltage - abort: no solution here
      available_buttons = Enum.filter(buttons, &Enum.member?(&1, index))
      available_presses = available_buttons |> Enum.map(fn button -> Enum.min(Enum.map(button, fn joltage_index -> elem(target_joltages, joltage_index) end)) end) |> Enum.sum()
      required_presses = elem(target_joltages, index)
      available_presses < required_presses
    end)

    if has_missing_button do
      # IO.inspect({"missing_button", length(buttons), tuple_sum(target_joltages), target_joltages, buttons})
      nil
    else
      ## IO.inspect({"step", length(buttons), tuple_sum(target_joltages), target_joltages})
      buttons_for_joltage = Enum.map(0..tuple_size(target_joltages)-1, fn index ->
        Enum.filter(buttons, fn button ->
          Enum.any?(button, fn joltage_index -> joltage_index == index end)
        end) #|> IO.inspect()
        # |> Enum.sort_by(fn button -> length(button) end, :desc)
      end) |> Enum.filter(fn buttons -> length(buttons) == 1 end) # |> Enum.sort_by(fn buttons -> length(buttons) end)
      |> Enum.flat_map(fn buttons -> buttons end)
      # IO.inspect({"step", length(buttons), tuple_sum(target_joltages), target_joltages, buttons_for_joltage, buttons})

      if buttons_for_joltage != [] do
        Stream.map(buttons_for_joltage, &joltages_setup_combination_length_try_button(tid, &1, buttons, target_joltages))
        |> Stream.filter(&(&1 != nil)) |> Enum.at(0, nil)
      else
        max = buttons |> Enum.map(fn button -> Enum.min(Enum.map(button, fn joltage_index -> elem(target_joltages, joltage_index) end)) end) |> Enum.max()
        buttons_by_length = Enum.chunk_by(buttons, &length/1)
        Stream.map(buttons_by_length, fn current_buttons ->
          # current_buttons = buttons
          Stream.map(0..max, fn limit ->
            # limit = 0
            Stream.map(current_buttons, &joltages_setup_combination_length_try_button(tid, &1, buttons, target_joltages, limit)) |> Stream.filter(&(&1 != nil)) |> Enum.at(0, nil)
          end) |> Stream.filter(&(&1 != nil)) |> Enum.at(0, nil)
        end) |> Stream.filter(&(&1 != nil)) |> Enum.at(0, nil)
      end
    end
    # end)
  end

  defp joltages_setup_combination_length_try_button(tid, button, buttons, target_joltages, limit \\ 0) do
    max_presses = Enum.min(Enum.map(button, fn joltage_index -> elem(target_joltages, joltage_index) end))
    if max_presses < limit do
      nil
    else
      rest_of_buttons = List.delete(buttons, button)
      presses = max_presses - limit
      new_target_joltages = tuple_increment_indexes(target_joltages, button, -presses)
      # IO.inspect({"inner_step", limit, length(rest_of_buttons), tuple_sum(new_target_joltages), new_target_joltages, button, presses, tuple_sum(target_joltages), target_joltages})
      # if limit != 0 do
      #   IO.inspect({"limit", limit})
      # end
      value = cond do
        # presses == 0 -> nil
        all_zero(new_target_joltages) -> 0
        any_negative(new_target_joltages) -> nil
        true -> joltages_setup_combination_length(tid, rest_of_buttons, new_target_joltages)
      end

      if value == nil do
        nil
      else
        value + presses
      end
    end
  end

  # defp has_valid_joltages_setup_combination(%Machine{joltages: joltages}, current_joltages, 0) do
  #   current_joltages == joltages
  # end

  # defp has_valid_joltages_setup_combination(%Machine{joltages_buttons: buttons, joltages: joltages} = machine, current_joltages, limit) do
  #   Enum.any?(buttons, fn button ->
  #     current_joltages = Enum.reduce(button, current_joltages, fn index, acc -> tuple_increment_index(acc, index) end)
  #     if all_lower_or_equal(current_joltages, joltages) do
  #       has_valid_joltages_setup_combination(machine, current_joltages, limit - 1)
  #     else
  #       false
  #     end
  #   end)
  # end

  defp lights_setup_combination_length(machine) do
    Stream.iterate(0, &(&1 + 1))
    |> Stream.map(fn limit -> {limit, has_valid_lights_setup_combination(machine.lights_buttons, initial_lights(machine), machine.lights, limit)} end)
    |> Stream.filter(fn {_limit, valid?} -> valid? end)
    |> Stream.map(fn {limit, _valid?} -> limit end)
    |> Enum.at(0)
  end

  defp has_valid_lights_setup_combination(_, current_lights, target_lights, 0) do
    target_lights == current_lights
  end

  defp has_valid_lights_setup_combination([], _, _, _) do
    false
  end

  defp has_valid_lights_setup_combination([button | remaining_buttons], current_lights, target_lights, limit) do
    has_valid_lights_setup_combination(remaining_buttons, bxor(current_lights, button), target_lights, limit - 1) or
    has_valid_lights_setup_combination(remaining_buttons, current_lights, target_lights, limit)
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

  defp parse_machine(["(" <> section | rest], %Machine{lights_buttons: lights_buttons, joltages_buttons: joltages_buttons} = machine) do
    # Button
    section = section |> String.trim_trailing(")")
    parse_machine(rest, %{machine | lights_buttons: [parse_indices_button(section) | lights_buttons], joltages_buttons: [parse_indexed_button(section) | joltages_buttons] })
  end

  defp parse_machine(["{" <> section | rest], %Machine{} = machine) do
    # Joltages
    section = section |> String.trim_trailing("}")
    parse_machine(rest, %{machine | joltages: parse_joltages(section)})
  end

  defp parse_machine([], %Machine{joltages_buttons: joltages_buttons} = machine) do
    sorted_joltages_buttons = Enum.sort_by(joltages_buttons, fn buttons -> length(buttons) end, :desc)
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
    lights = section
    |> String.to_charlist()
    |> Enum.map(&parse_lightstate/1)
    # |> List.to_tuple()
    {length(lights), bitmap_to_number(lights)}
  end

  defp parse_lightstate(?#), do: true
  defp parse_lightstate(?.), do: false

  defp validate_machine(%AoC2025.Puzzle.Day10.Machine{lights: lights, lights_length: lights_length, lights_buttons: lights_buttons, joltages_buttons: joltages_buttons, joltages: joltages} = machine) do
    max_lights = 0..lights_length-1 |> Enum.map(fn _ -> true end) |> bitmap_to_number()
    cond do
      lights == nil -> raise "Lights not found"
      lights_length == nil -> raise "Lights length not found"
      lights_buttons == [] -> raise "Lights buttons not found"
      joltages_buttons == [] -> raise "Joltages buttons not found"
      joltages == nil -> raise "Joltages not found"
      Enum.any?(lights_buttons, fn lights_bitmap -> lights_bitmap > max_lights or lights_bitmap < 0 end) -> raise "Lights button contains invalid light ID"
      Enum.any?(joltages_buttons, &Enum.any?(&1, fn joltage_index -> joltage_index >= tuple_size(joltages) or joltage_index < 0 end)) -> raise "Joltages button contains invalid joltage index"
      lights_length != tuple_size(joltages) -> raise "Lights and joltages must have the same length"
      true -> machine
    end
  end

  defp bitmap_to_number([true | rest]) do
    (bitmap_to_number(rest) <<< 1) ||| 1
  end

  defp bitmap_to_number([false | rest]) do
    bitmap_to_number(rest) <<< 1
  end

  defp bitmap_to_number([]) do
    0
  end

  defp indices_to_number([index | rest]) do
    indices_to_number(rest) ||| (1 <<< index)
  end

  defp indices_to_number([]) do
    0
  end

  defp initial_lights(%Machine{lights: _lights}) do
    0
  end

  defp initial_joltages(%Machine{joltages: joltages}) do
    joltages |> Tuple.to_list() |> Enum.map(fn _ -> 0 end) |> List.to_tuple()
  end

  defp tuple_increment_indexes(tuple, indexes, by \\ 1) do
    Enum.reduce(indexes, tuple, fn index, tuple -> tuple_increment_index(tuple, index, by) end)
  end

  defp tuple_increment_index(tuple, index, by \\ 1) do
    value = elem(tuple, index)
    value = value + by
    put_elem(tuple, index, value)
  end

  defp tuple_sum(tuple) do
    Enum.sum(Tuple.to_list(tuple))
  end

  defp any_negative(tuple) do
    Enum.any?(Tuple.to_list(tuple), &(&1 < 0))
  end

  defp all_zero(tuple) do
    Enum.all?(Tuple.to_list(tuple), &(&1 == 0))
  end

  defp all_lower_or_equal(a, b) do
    Enum.zip(Tuple.to_list(a), Tuple.to_list(b)) |> Enum.all?(fn {a, b} -> a <= b end)
  end

  defp memoized(tid, key, fun) do
    case :ets.lookup(tid, key) do
      [{^key, result}] ->
        result

      _ ->
        result = fun.()
        :ets.insert(tid, {key, result})
        result
    end
  end

  import AoC2025.Runner
  defrunner(Part1, id: "day10", name: "Day 10 - Part 1", do: part1)
  defrunner(Part2, id: "day10", name: "Day 10 - Part 2", do: part2)
end
