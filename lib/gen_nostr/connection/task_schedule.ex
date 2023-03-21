defmodule GenNostr.Connection.TaskSchedule do
  @moduledoc false

  def garbage_collector(tasks) do
    time = Keyword.get(tasks, :garbage_collector)

    if time != 0 do
      Process.send_after(self(), {:"$gen_cast", :garbage_collector}, time)
    end
  end
end
