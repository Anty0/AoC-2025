defmodule AoC2025.Runner do
  defmacro defrunner(module_name, id: id, name: name, do: fun_atom) do
    caller = __CALLER__.module

    quote do
      defmodule unquote(module_name) do
        def id, do: unquote(id)
        def name, do: unquote(name)
        def solve(input), do: unquote(caller).unquote(fun_atom)(input)
      end
    end
  end

  defmacro runnertest(module, opts) do
    Enum.map(opts, fn {suffix, value} ->
      quote do
        defmodule Module.concat([unquote(module), "Test_", unquote(suffix)]) do
          use ExUnit.Case, async: true

          @path Path.join(
                  AoC2025.Constants.input_dir(),
                  "#{unquote(module).id()}.#{unquote(suffix)}.txt"
                )

          @tag if(File.exists?(@path), do: [], else: [skip: true])
          test unquote(suffix) do
            assert unquote(module).solve(File.stream!(@path)) == unquote(value)
          end
        end
      end
    end)
  end
end
