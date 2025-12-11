defmodule AoC2025.Dantzig.HiGS do
  # Modified version of the original module. Fixes:
  # - Use default system wide HiGS solver (the original module has hardcoded path to executable...)
  # - Implements support for integer variables (the original module doesn't print them under General section)

  require Dantzig.Problem, as: Problem
  alias Dantzig.Constraint
  alias Dantzig.ProblemVariable
  alias Dantzig.Solution
  alias Dantzig.Polynomial

  @max_random_prefix 2 ** 32

  def solve(%Problem{} = problem) do
    iodata = to_lp_iodata(problem)

    with_temporary_files(["model.lp", "solution.lp"], fn [model_path, solution_path] ->
      File.write!(model_path, iodata)

      {output, _error_code} =
        System.cmd("highs", [
          model_path,
          "--solution_file",
          solution_path
        ])

      solution_contents =
        case File.read(solution_path) do
          {:ok, contents} ->
            contents

          {:error, :enoent} ->
            raise RuntimeError, """
            Couldn't generate a solution for the given problem.

            Input problem/model file:

            #{indent(iodata, 4)}
            Output from the HiGHS solver:

            #{indent(output, 4)}
            """
        end

      Solution.from_file_contents!(solution_contents)
    end)
  end

  defp indent(iodata, indent_level) do
    binary = to_string(iodata)
    spaces = String.duplicate(" ", indent_level)

    binary
    |> String.split("\n")
    |> Enum.map(fn line -> [spaces, line, "\n"] end)
  end

  defp with_temporary_files(basenames, fun) do
    dir = System.tmp_dir!()
    prefix = :rand.uniform(@max_random_prefix) |> Integer.to_string(32)

    paths =
      for basename <- basenames do
        Path.join(dir, "#{prefix}_#{basename}")
      end

    try do
      fun.(paths)
    after
      for path <- paths do
        try do
          File.rm!(path)
        rescue
          _ -> :ok
        end
      end
    end
  end

  defp constraint_to_iodata(constraint = %Constraint{}) do
    [
      "  ",
      constraint.name,
      ": ",
      Polynomial.to_lp_constraint(constraint.left_hand_side),
      " ",
      operator_to_iodata(constraint.operator),
      " ",
      to_string(constraint.right_hand_side),
      "\n"
    ]
  end

  defp operator_to_iodata(operator) do
    case operator do
      :== -> "="
      other -> to_string(other)
    end
  end

  defp direction_to_iodata(:maximize), do: "Maximize"
  defp direction_to_iodata(:minimize), do: "Minimize"

  def to_lp_iodata(%Problem{} = problem) do
    constraints = Enum.sort(problem.constraints)

    constraints_iodata =
      Enum.map(constraints, fn {_id, constraint} ->
        constraint_to_iodata(constraint)
      end)

    bounds = all_variable_bounds(Map.values(problem.variables))
    integer_variables = all_variable_integers(Map.values(problem.variables))

    [
      direction_to_iodata(problem.direction),
      "\n  ",
      Polynomial.to_lp_iodata_objective(problem.objective),
      "\n",
      "Subject To\n",
      constraints_iodata,
      "Bounds\n",
      bounds,
      "General\n",
      integer_variables,
      "End\n"
    ]
  end

  defp variable_bounds(%ProblemVariable{} = v) do
    case {v.min, v.max} do
      {nil, nil} ->
        "  #{v.name} free\n"

      {nil, max} ->
        "  #{v.name} <= #{max}\n"

      {min, nil} ->
        "  #{min} <= #{v.name}\n"

      {min, max} ->
        "  #{min} <= #{v.name}\n  #{v.name} <= #{max}\n"
    end
  end

  defp all_variable_bounds(variables) do
    Enum.map(variables, &variable_bounds/1)
  end

  defp variable_integer(%ProblemVariable{} = v) do
    case v.type do
      :integer ->
        "  #{v.name}\n"

      _ ->
        ""
    end
  end

  defp all_variable_integers(variables) do
    Enum.map(variables, &variable_integer/1)
  end
end
