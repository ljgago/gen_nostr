####################
# Websocket commands

defmodule GenNostr.Commands.AddRelay do
  @moduledoc false

  defstruct [:relay]

  @type t :: %__MODULE__{}
end

defmodule GenNostr.Commands.RemoveRelay do
  @moduledoc false

  defstruct [:relay]

  @type t :: %__MODULE__{}
end

defmodule GenNostr.Commands.Reconnect do
  @moduledoc false

  defstruct [:relay]

  @type t :: %__MODULE__{}
end

defmodule GenNostr.Commands.ListRelays do
  @moduledoc false

  defstruct []

  @type t :: %__MODULE__{}
end

defmodule GenNostr.Commands.SendMessage do
  @moduledoc false

  defstruct [:url, :message]

  @type t :: %__MODULE__{}
end

defmodule GenNostr.Commands.BroadcastMessage do
  @moduledoc false

  defstruct [:message]

  @type t :: %__MODULE__{}
end

defmodule GenNostr.Commands.CollectGarbage do
  @moduledoc false

  defstruct []

  @type t :: %__MODULE__{}
end

defmodule GenNostr.Commands.PublishEvent do
  @moduledoc false

  defstruct [:event]

  @type t :: %__MODULE__{}
end

defmodule GenNostr.Commands.Subscribe do
  @moduledoc false

  defstruct [:sub_id, :filters]

  @type t :: %__MODULE__{}
end

defmodule GenNostr.Commands.CloseSubscription do
  @moduledoc false

  defstruct [:sub_id]

  @type t :: %__MODULE__{}
end
