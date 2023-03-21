##################
# Websocket events

defmodule GenNostr.Events.Connected do
  @moduledoc false

  defstruct [:relay]

  @type t :: %__MODULE__{}
end

defmodule GenNostr.Events.Disconnected do
  @moduledoc false

  defstruct [:reason, :relay]

  @type t :: %__MODULE__{}
end

defmodule GenNostr.Events.Closed do
  @moduledoc false

  defstruct [:reason, :relay]

  @type t :: %__MODULE__{}
end

defmodule GenNostr.Events.Error do
  @moduledoc false

  defstruct [:reason, :relay]

  @type t :: %__MODULE__{}
end

##############
# Nostr events

defmodule GenNostr.Events.Event do
  @moduledoc false

  defstruct [:message, :relay]

  @type t :: %__MODULE__{}
end

defmodule GenNostr.Events.Notice do
  @moduledoc false

  defstruct [:message, :relay]

  @type t :: %__MODULE__{}
end

defmodule GenNostr.Events.Eose do
  @moduledoc false

  defstruct [:message, :relay]

  @type t :: %__MODULE__{}
end

defmodule GenNostr.Events.Ok do
  @moduledoc false

  defstruct [:message, :relay]

  @type t :: %__MODULE__{}
end

defmodule GenNostr.Events.Auth do
  @moduledoc false

  defstruct [:message, :relay]

  @type t :: %__MODULE__{}
end
