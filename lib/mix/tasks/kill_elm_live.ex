defmodule Mix.Tasks.KillElmLive do
  use Mix.Task

  @shortdoc "Kills elm-live node server"

  def run([]) do
    case Mix.shell().cmd("if [ $(lsof -t -i:8000) ];then pkill node;fi", stderr_to_stdout: true) do
      0 -> :ok
      a -> raise "kill_elm_live failure exit code: #{a}"
    end
  end
end
