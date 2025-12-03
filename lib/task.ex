defmodule Mix.Tasks.RunApp do
  use Mix.Task

  def run(_args) do
    Mix.Task.run("app.start")
    AoC2025.runAll()
  end
end
