defmodule PeriodicalTimer do
  use GenServer
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end
  def start_timer(pid, period_ms, callback_fun) when is_function(callback_fun) do
    GenServer.cast(pid, {:start_timer, period_ms, callback_fun})
  end
  def cancel_timer(pid) do
    GenServer.cast(pid, :cancel_timer)
  end
  def init(:ok) do
    {:ok, []} # Store active timers in the state
  end
  def handle_cast({:start_timer, period_ms, callback_fun}, state) do
    timer_ref = Process.send_after(self(), :tick, period_ms)
    {:noreply, [{timer_ref, callback_fun} | state]}
  end
  def handle_cast(:cancel_timer, state) do
    cancel_all_timers(state)
  end
  def handle_info(:tick, state) do
    new_state = handle_timers(state)
    {:noreply, new_state}
  end
  defp cancel_all_timers(state) do
    Enum.each(state, fn {timer_ref, _callback_fun} ->
      Process.cancel_timer(timer_ref)
    end)
    {:noreply, []}
  end
  defp handle_timers(state) do
    Enum.reduce(state, [], fn {timer_ref, callback_fun}, acc ->
      case callback_fun.() do
        :ok -> [{timer_ref, callback_fun} | acc]
        :cancel ->
          Process.cancel_timer(timer_ref)
          acc
      end
    end)
  end
end
