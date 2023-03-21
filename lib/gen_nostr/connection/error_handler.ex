defmodule GenNostr.Connection.ErrorHandler do
  @moduledoc false

  alias GenNostr.Events
  alias GenNostr.Connection.State

  def transport_error(%Mint.TransportError{reason: reason}, state) do
    transport_error(reason, state)
  end

  def transport_error({_error, reason}, state) do
    transport_error(reason, state)
  end

  def transport_error(reason, state) do
    case reason do
      reason when reason in [:econnrefused, :nxdomain, :closed] ->
        Events.route_event(state.module, %Events.Error{reason: reason, relay: state.relay})
        %State{state | closing?: true}

      _ ->
        Events.route_event(state.module, %Events.Error{reason: reason, relay: state.relay})
        state
    end
  end

  def close_connection(%Mint.TransportError{reason: reason}, state) do
    close_connection(reason, state)
  end

  def close_connection(reason, state) do
    case reason do
      reason when reason in [:econnrefused, :nxdomain] ->
        {:stop, {:shutdown, reason}, state}

      _ ->
        Events.route_event(state.module, %Events.Disconnected{reason: reason, relay: state.relay})
        Mint.HTTP.close(state.conn)
        {:stop, {:shutdown, reason}, state}
    end
  end
end
