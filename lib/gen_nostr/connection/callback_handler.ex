defmodule GenNostr.Connection.CallbackHandler do
  @moduledoc false

  alias GenNostr.Events

  def handle_callback(<<"[\"EVENT\"", _rest::binary>> = message, state) do
    Events.route_event(state.module, %Events.Event{message: message, relay: state.relay})
    state
  end

  def handle_callback(<<"[\"NOTICE\"", _rest::binary>> = message, state) do
    Events.route_event(state.module, %Events.Notice{message: message, relay: state.relay})
    state
  end

  def handle_callback(<<"[\"EOSE\"", _rest::binary>> = message, state) do
    Events.route_event(state.module, %Events.Event{message: message, relay: state.relay})
    state
  end

  def handle_callback(<<"[\"OK\"", _rest::binary>> = message, state) do
    Events.route_event(state.module, %Events.Ok{message: message, relay: state.relay})
    state
  end

  def handle_callback(<<"[\"AUTH\"", _rest::binary>> = message, state) do
    Events.route_event(state.module, %Events.Auth{message: message, relay: state.relay})
    state
  end

  # Any other message
  def handle_callback(_message, state), do: state
end
