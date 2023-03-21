defmodule GenNostr.Options do
  @moduledoc false

  defstruct mint: [protocols: [:http1]],
            reconnect: [500, 1_000, 5_000, 10_000, 30_000],
            tasks: [
              garbage_collector: 60 * 60 * 1000,
            ]

  @type t :: %__MODULE__{
          mint: keyword(),
          tasks: keyword()
        }

  @doc """
  Create a new Options structure with default values.
  """
  @spec new() :: t()
  def new() do
    %__MODULE__{}
  end

  @doc """
  Create a new Options structure with the keywords params.
  """
  @spec new(keyword()) :: t()
  def new(fields) do
    struct(%__MODULE__{}, fields)
  end

  @doc """
  Update the Options structure with the keywords params.
  """
  @spec update(t(), keyword()) :: t()
  def update(options, fields) do
    struct(options, fields)
  end
end
