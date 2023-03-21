defmodule GenNostr.Connection.ControlFlow do
  @moduledoc false

  require Logger

  import GenNostr.Signatures, only: [command: 1]

  alias GenNostr.{Commands, Events}
  alias GenNostr.Connection.{State, CallbackHandler, ErrorHandler, TaskSchedule, Sender}

  #################
  # Connect handler

  def handle_connect(%{relay: %{url: url, options: options}} = state) do
    uri = URI.parse(url)

    TaskSchedule.garbage_collector(options.tasks)

    http_scheme = map_http_scheme(uri.scheme)
    ws_scheme = map_ws_scheme(uri.scheme)
    path = map_path(uri)

    with {:ok, conn} <- Mint.HTTP.connect(http_scheme, uri.host, uri.port, options.mint),
         {:ok, conn, ref} <-
           Mint.WebSocket.upgrade(ws_scheme, conn, path, [{"user-agent", "gen-nostr"}]) do
      state = %State{state | conn: conn, request_ref: ref}
      {:noreply, state}
    else
      {:error, reason} ->
        state = ErrorHandler.transport_error(reason, state)
        {:stop, {:shutdown, reason}, state}

      {:error, conn, reason} ->
        state = ErrorHandler.transport_error(reason, %State{state | conn: conn})
        {:stop, {:shutdown, reason}, state}

      reason ->
        state = ErrorHandler.transport_error(reason, state)
        {:stop, {:shutdown, reason}, state}
    end
  end

  defp map_http_scheme("wss"), do: :https
  defp map_http_scheme(_), do: :http

  defp map_ws_scheme("wss"), do: :wss
  defp map_ws_scheme(_), do: :ws

  defp map_path(uri) do
    case uri.query do
      nil -> uri.path || "/"
      query -> uri.path <> "?" <> query
    end
  end

  ###########################
  # Websocket message handler

  def handle_info(message, state) do
    case Mint.WebSocket.stream(state.conn, message) do
      {:ok, conn, responses} ->
        state = handle_responses(responses, %State{state | conn: conn})

        if state.closing?,
          do: ErrorHandler.close_connection(message, state),
          else: {:noreply, state}

      {:error, conn, reason, _responses} ->
        state = ErrorHandler.transport_error(reason, %State{state | conn: conn})

        if state.closing?,
          do: ErrorHandler.close_connection(reason, state),
          else: {:noreply, state}

      :unknown ->
        {:noreply, state}
    end
  end

  defp handle_responses(responses, state)

  defp handle_responses([{:status, ref, status} | rest], %{request_ref: ref} = state) do
    handle_responses(rest, %State{state | status: status})
  end

  defp handle_responses([{:headers, ref, resp_headers} | rest], %{request_ref: ref} = state) do
    handle_responses(rest, %State{state | resp_headers: resp_headers})
  end

  defp handle_responses([{:done, ref} | rest], %{request_ref: ref} = state) do
    case Mint.WebSocket.new(state.conn, ref, state.status, state.resp_headers) do
      {:ok, conn, websocket} ->
        Events.route_event(state.module, %Events.Connected{relay: state.relay})
        state = %State{state | conn: conn, websocket: websocket, status: nil, resp_headers: nil}
        handle_responses(rest, state)

      {:error, conn, reason} ->
        ErrorHandler.transport_error(reason, %State{state | conn: conn})
    end
  end

  defp handle_responses(
         [{:data, ref, data} | rest],
         %{request_ref: ref, websocket: websocket} = state
       )
       when websocket != nil do
    case Mint.WebSocket.decode(websocket, data) do
      {:ok, websocket, frames} ->
        state = handle_frames(frames, %State{state | websocket: websocket})
        handle_responses(rest, state)

      {:error, websocket, reason} ->
        ErrorHandler.transport_error(reason, %State{state | websocket: websocket})
    end
  end

  defp handle_responses([_response | rest], state) do
    handle_responses(rest, state)
  end

  defp handle_responses([], state), do: state

  ################
  # Handler frames

  def handle_frames(frames, state) do
    Enum.reduce(frames, state, fn
      {:ping, data}, state ->
        Logger.debug("PING from #{inspect(state.relay.url)}")
        Sender.send_message({:pong, data}, state)

      {:pong, _data}, state ->
        Logger.debug("PONG from #{inspect(state.relay.url)}")
        state

      {:close, _code, _data}, state ->
        %State{state | closing?: true}

      {encoding, message}, state when encoding in [:text, :binary] ->
        CallbackHandler.handle_callback(message, state)
    end)
  end

  ##############
  # Handle tasks

  def handle_cast(:garbage_collector, %{relay: %{options: options}} = state) do
    :erlang.garbage_collect(self())
    Logger.debug("Collect garbage from #{inspect(state.relay)}")

    TaskSchedule.garbage_collector(options.tasks)

    {:noreply, state}
  end

  #################
  # Handle commands

  def handle_cast(command(%Commands.SendMessage{message: message}), state) do
    {:noreply, Sender.send_message(message, state)}
  end

  def handle_cast(command(%Commands.RemoveRelay{}), state) do
    ErrorHandler.close_connection(:remove_relay, state)
  end

  def handle_cast(command(%Commands.CollectGarbage{}), state) do
    :erlang.garbage_collect(self())
    {:noreply, state}
  end

  def handle_cast(cmd, state) do
    Logger.debug("Command without handler #{inspect(cmd)}")
    {:noreply, state}
  end

  ##################
  # Handle terminate

  def terminate(reason, state) do
    Events.route_event(state.module, %Events.Disconnected{reason: reason, relay: state.relay})

    state
  end
end
