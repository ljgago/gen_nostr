defmodule GenNostr.Connection.State do
  @moduledoc false

  defstruct [
    :module,
    :relay,
    :conn,
    :request_ref,
    :websocket,
    :status,
    :resp_headers,
    :options,
    closing?: false
  ]

  @type t :: %__MODULE__{
  }

  @doc """

  """
  @spec new(keyword()) :: t()
  def new(fields) do
    struct(__MODULE__, fields)
  end

  @doc """

  """
  @spec update(t(), keyword()) :: t()
  def update(state, fields) do
    struct(state, fields)
  end

end
