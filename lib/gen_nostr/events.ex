defmodule GenNostr.Events do
  @moduledoc false

  import GenNostr.Signatures, only: [event: 1]

  @spec route_event(Proccess.dest(), struct()) :: any()
  def route_event(dest, event) do
    send(dest, event(event))
  end
end
