defmodule PeriodicalTimerScript do
  Code.require_file("periodical_timer.ex")
  def sample_callback_fun do
    IO.puts("Timer ticked!")
    :ok
  end
  def run do
    {:ok, timer_pid} = PeriodicalTimer.start_link()
    PeriodicalTimer.start_timer(timer_pid, 1000, &sample_callback_fun/0)
    Process.sleep(10_000)
    PeriodicalTimer.cancel_timer(timer_pid)
  end
end
PeriodicalTimerScript.run()
