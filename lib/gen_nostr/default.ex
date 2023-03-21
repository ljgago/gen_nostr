defmodule GenNostr.Default do
  @moduledoc false

  # a module providing default implementations for GenNostr callbacks

  @behaviour GenNostr

  # import GenNostr, only: [remove_relay: 1]

  @impl GenNostr
  def init(args), do: {:ok, args}

  @impl GenNostr
  def terminate(_reason, _state), do: :ok

  @impl GenNostr
  def handle_info(_message, state), do: {:noreply, state}

  @impl GenNostr
  def handle_connect(_relay, state), do: {:ok, state}

  @impl GenNostr
  def handle_disconnect(_reason, _relay, state), do: {:ok, state}

  @impl GenNostr
  def handle_event({_susbscription_id, _event}, _relay, state), do: {:ok, state}

  @impl GenNostr
  def handle_notice({_message}, _relay, state), do: {:ok, state}

  @impl GenNostr
  def handle_eose({_subscription_id}, _relay, state), do: {:ok, state}

  @impl GenNostr
  def handle_ok({_event_id, _success?, _message}, _relay, state), do: {:ok, state}

  @impl GenNostr
  def handle_auth({_challenge}, _relay, state), do: {:ok, state}

  def __no_op__(_event, _relay, state), do: {:ok, state}
end
