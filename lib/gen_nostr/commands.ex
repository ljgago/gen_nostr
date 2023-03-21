defmodule GenNostr.Commands do
  @moduledoc false

  import GenNostr.Signatures, only: [command: 1]

  alias GenNostr.{ConnectionSupervisor, Commands, Relay}

  @spec route_command(struct()) :: any()
  def route_command(cmd)

  def route_command(%Commands.AddRelay{relay: relay}) do
    relay = Relay.normalize(relay)
    ConnectionSupervisor.start_child(relay)
  end

  def route_command(%Commands.RemoveRelay{relay: relay} = cmd) do
    pid_from_url(relay.url)
    |> GenServer.cast(command(cmd))
  end

  def route_command(%Commands.Reconnect{relay: relay}) do
    {time, relay} = Relay.next_reconnect_time(relay)

    Process.send_after(
      self(),
      {:"$gen_cast", command(%Commands.Reconnect{relay: relay})},
      time
    )
  end

  def route_command(%Commands.SendMessage{url: url} = cmd) do
    pid_from_url(url)
    |> GenServer.cast(command(cmd))
  end

  def route_command(%Commands.BroadcastMessage{message: message}) do
    for pid <- Registry.select(GenNostr.ConnectionRegistry, [{{:_, :"$1", :_}, [], [:"$1"]}]) do
      GenServer.cast(pid, command(%Commands.SendMessage{message: message}))
    end
  end

  def route_command(%Commands.ListRelays{}) do
    Registry.select(GenNostr.ConnectionRegistry, [{{:"$1", :_, :_}, [], [:"$1"]}])
  end

  def route_command(%Commands.CollectGarbage{} = cmd) do
    for pid <- Registry.select(GenNostr.ConnectionRegistry, [{{:_, :"$1", :_}, [], [:"$1"]}]) do
      GenServer.cast(pid, command(cmd))
    end
  end

  #########
  # Helpers

  defp pid_from_url(url) do
    url = Relay.normalize_url(url)

    case Registry.lookup(GenNostr.ConnectionRegistry, url) do
      [{pid, _}] -> pid
      _ -> raise "relay #{url} is not registred"
    end
  end
end
