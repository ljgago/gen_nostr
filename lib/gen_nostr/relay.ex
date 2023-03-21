defmodule GenNostr.Relay do
  @moduledoc false

  defstruct url: "",
            uptime: 0,
            reconnect_counter: 0,
            options: %GenNostr.Options{}

  @type t :: %__MODULE__{
          url: String.t(),
          uptime: non_neg_integer(),
          reconnect_counter: non_neg_integer(),
          options: GenNostr.Options.t()
        }

  @doc """
  Create a new Relay structure with default values.
  """
  @spec new() :: t()
  def new do
    %__MODULE__{}
  end

  @doc """
  Create a new Relay structure with the keywords params.
  """
  @spec new(keyword()) :: t()
  def new(fields) do
    struct(__MODULE__, fields)
  end

  @doc """
  Update the Relay structure with the keywords params.
  """
  @spec update(t(), keyword()) :: t()
  def update(relay, fields) do
    struct(relay, fields)
  end

  @doc """
  Normalize the url from a Relay structure.
  """
  @spec normalize(t()) :: t()
  def normalize(relay) do
    %__MODULE__{relay | url: normalize_url(relay.url)}
  end

  @doc """
  Normalize the url.
  """
  @spec normalize_url(String.t()) :: String.t()
  def normalize_url(url) do
    {:ok, uri} =
      case URI.parse(url) do
        %URI{scheme: nil} ->
          {:error, "is missing a scheme (e.g. wss): `#{url}`"}

        %URI{host: nil} ->
          {:error, "is missing a host"}

        uri ->
          {:ok, uri}
      end

    # remove repeated slashes
    path =
      case uri.path do
        nil ->
          "/"

        "/" ->
          "/"

        path ->
          Regex.replace(~r/\/+/, path, "/")
          |> String.trim_trailing("/")
      end

    # sort the query params
    query =
      case uri.query do
        nil ->
          nil

        query ->
          URI.query_decoder(query)
          |> Map.new()
          |> Enum.map(fn {k, v} -> {k, v} end)
          |> URI.encode_query()
      end

    %URI{
      scheme: uri.scheme,
      host: uri.host,
      port: uri.port,
      path: path,
      query: query
    }
    |> URI.to_string()
  end

  @doc """
  Verify the url format.
  """
  @spec verify_url(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def verify_url(url) do
    re = Regex.compile!("\\w+:(\\/\\/)[^\\s]")

    if String.match?(url, re) do
      {:ok, url}
    else
      {:error, "wrong url format: `#{url}`"}
    end
  end

  @doc false
  @spec next_reconnect_time(t()) :: {non_neg_integer(), t()}
  def next_reconnect_time(%__MODULE__{} = relay) do
    relay = update_in(relay, [Access.key(:reconnect_counter)], &(&1 + 1))

    time =
      retry_time(
        relay.options.reconnect,
        relay.reconnect_counter - 1
      )

    {time, relay}
  end

  defp retry_time(backoff_times, try_number) do
    # when we hit the end of the list, we repeat the last value in the list
    default = Enum.at(backoff_times, -1)

    Enum.at(backoff_times, try_number, default)
  end
end
