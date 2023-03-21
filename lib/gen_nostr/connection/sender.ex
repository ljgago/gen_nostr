defmodule GenNostr.Connection.Sender do
  @moduledoc false

  alias GenNostr.Connection.State
  alias GenNostr.Events

  ###########################
  # Push message to conection

  def send_message(message, state) do
    case send_frame(message, state) do
      {:ok, state} ->
        state

      {:error, state, reason} ->
        Events.route_event(state.module, %Events.Error{reason: {:send_failure, reason}, relay: state.relay})
        state
    end
  end

  defp send_frame(frame, state) when is_tuple(frame) or is_atom(frame) do
    with {:ok, websocket, data} <-
           Mint.WebSocket.encode(state.websocket, frame),
         {:ok, conn} <-
           Mint.WebSocket.stream_request_body(
             state.conn,
             state.request_ref,
             data
           ) do
      {:ok, %State{state | conn: conn, websocket: websocket}}
    else
      {:error, %Mint.WebSocket{} = websocket, reason} ->
        {:error, %State{state | websocket: websocket}, reason}

      {:error, conn, reason} ->
        {:error, %State{state | conn: conn}, reason}
    end
  end

  defp send_frame(message, state) do
    send_frame({:text, message}, state)
  end
end
