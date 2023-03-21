defmodule GenNostr.PrimarySupervisor do
  @moduledoc false

  use Supervisor

  def start_link(module) do
    Supervisor.start_link(__MODULE__, module, name: __MODULE__)
  end

  @impl Supervisor
  def init(module) do
    children = [
      {Registry, [keys: :unique, name: GenNostr.ConnectionRegistry]},
      {GenNostr.ConnectionSupervisor, module}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
