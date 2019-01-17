defmodule KeyValue.Worker do
  use GenServer

  def start_link(name) do
    IO.puts("Starting KV-#{name}")
    Swarm.register_name({__MODULE__, name}, __MODULE__, :start, [name])
  end

  def start(name) do
    IO.puts("Starting KV-#{name}")
    GenServer.start_link(__MODULE__, [])
  end

  def put(server, key, value) do
    GenServer.cast(server, {:put, key, value})
  end

  def get(server, key) do
    GenServer.call(server, {:get, key})
  end

  def whereis(name) do
    case Swarm.whereis_name({__MODULE__, name}) do
      :undefined -> nil
      pid -> pid
    end
  end

  @impl GenServer
  def init(_) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_cast({:put, key, value}, store) do
    {:noreply, Map.put(store, key, value)}
  end

  @impl GenServer
  def handle_call({:get, key}, _, store) do
    {:reply, Map.get(store, key), store}
  end

  def handle_cast({:swarm, :end_handoff, previous_state}, _state) do
    {:noreply, previous_state}
  end

  def handle_cast({:swarm, :resolve_conflict, other_state}, _state) do
    {:noreply, other_state}
  end

  def handle_call({:swarm, :begin_handoff}, _from, state) do
    {:reply, {:resume, state}, state}
  end

  def handle_info({:swarm, :die}, state) do
    {:stop, :shutdown, state}
  end
end
