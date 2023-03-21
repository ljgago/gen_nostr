defmodule GenNostr.ConnectionSupervisor do
  @moduledoc false

  @child GenNostr.Connection

  use DynamicSupervisor

  @doc false
  def start_link(module) do
    DynamicSupervisor.start_link(__MODULE__, module, name: __MODULE__)
  end

  @doc false
  def start_child(relay) do
    spec = %{
      id: @child,
      start: {@child, :start_link, [relay]},
      restart: :transient,
      type: :worker
    }

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @doc false
  def terminate_child(url) do
    url = GenNostr.Relay.normalize_url(url)
    [{pid, _}] = Registry.lookup(GenNostr.ConnectionRegistry, url)
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  @doc false
  @impl DynamicSupervisor
  def init(module) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [module]
    )
  end
end
