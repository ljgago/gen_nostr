defmodule GenNostr.Callback do
  @moduledoc false

  alias GenNostr.Events

  @known_callbacks [{:__no_op__, 2} | GenNostr.behaviour_info(:callbacks)]

  # dispatch an incoming event to a module's callback implementations
  # if the module does not implement the callback, it will be sent instead to
  # the default implementation in GenNostr.Default
  @spec dispatch(module :: module(), event :: struct(), state :: term()) ::
          {:noreply, new_state}
          | {:noreply, new_state, timeout() | :hibernate | {:continue, term()}}
          | {:stop, reason :: term(), new_state}
        when new_state: term()
  def dispatch(module, event, state) do
    {function, args} = determine_callback(event, state)

    dispatch_module =
      if function_exported?(module, function, length(args)) do
        module
      else
        GenNostr.Default
      end

    apply(dispatch_module, function, args)
    |> handle_callback_return()
  end

  defp handle_callback_return({:ok, state}), do: {:noreply, state}

  defp handle_callback_return({:ok, state, others}), do: {:noreply, state, others}

  defp handle_callback_return({:noreply, _state} = return), do: return

  defp handle_callback_return({:noreply, _state, _others} = return), do: return

  defp handle_callback_return({:stop, _reason, _state} = return), do: return

  # ensures at compile-time that the callback exists. useful for development
  @spec callback(atom(), [any()]) :: {atom(), [any() | Socket.t()]}
  defmacrop callback(name, args) do
    # add one for state
    # note that `args` needs to be a compile-time list for this to work
    arity = length(args) + 1

    unless {name, arity} in @known_callbacks do
      raise CompileError,
        file: __CALLER__.file,
        line: __CALLER__.line,
        description: "cannot wrap unknown callback #{name}/#{arity}"
    end

    quote do
      {unquote(name), unquote(args)}
    end
  end

  @spec determine_callback(struct(), term()) :: {atom(), list(any())}
  def determine_callback(event, state) do
    {name, args} = _determine_callback(event)

    # inject state as last arg, always
    {name, args ++ [state]}
  end

  defp _determine_callback(%Events.Connected{} = event) do
    callback(:handle_connect, [event.relay])
  end

  defp _determine_callback(%Events.Disconnected{} = event) do
    callback(:handle_disconnect, [event.reason, event.relay])
  end

  defp _determine_callback(%Events.Error{} = event) do
    callback(:handle_error, [event.reason, event.relay])
  end

  defp _determine_callback(%Events.Event{} = event) do
    callback(:handle_event, [event.message, event.relay])
  end

  defp _determine_callback(%Events.Notice{} = event) do
    callback(:handle_notice, [event.message, event.relay])
  end

  defp _determine_callback(%Events.Eose{} = event) do
    callback(:handle_eose, [event.message, event.relay])
  end

  defp _determine_callback(%Events.Ok{} = event) do
    callback(:handle_ok, [event.message, event.relay])
  end

  defp _determine_callback(%Events.Auth{} = event) do
    callback(:handle_auth, [event.message, event.relay])
  end

  defp _determine_callback(event) do
    callback(:handle_info, [event])
  end
end
