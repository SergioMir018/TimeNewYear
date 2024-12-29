defmodule TimeNewYear do
  use Application

  def start(_start_type, _start_args) do
    next_year = DateTime.utc_now().year + 1
    time = DateTime.new!(Date.new!(next_year, 1, 1), Time.new!(0, 0, 0, 0), "Etc/UTC")

    children = [
      {TimeNewYear.Worker, time}
    ]

    # Iniciar el supervisor
    opts = [strategy: :one_for_one, name: TimeNewYear.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule TimeNewYear.Worker do
  use GenServer

  # Public API
  def start_link(time) do
    GenServer.start_link(__MODULE__, time, name: __MODULE__)
  end

  # GenServer Callbacks
  def init(time) do
    schedule_tick()
    {:ok, time}
  end

  def handle_info(:tick, time) do
    time_till = DateTime.diff(time, DateTime.utc_now())

    days_left = div(time_till, 86400)
    hours_left = div(rem(time_till, 86400), 3600)
    mins_left = div(rem(time_till, 3600), 60)
    secds_left = rem(time_till, 60)

    IO.puts("Time left till next year: #{days_left}d #{hours_left}h #{mins_left}m #{secds_left}s")

    # Programar el siguiente tick
    schedule_tick()

    {:noreply, time}
  end

  # Helper Functions
  defp schedule_tick do
    Process.send_after(self(), :tick, 1000)  # Programar la próxima ejecución en 1 segundo
  end
end
