defmodule KeyValue.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {
        Cluster.Supervisor,
        [Application.get_env(:libcluster, :topologies), [name: __MODULE__.ClusterSupervisor]]
      },
      KeyValue.Cache
    ]
    opts = [strategy: :one_for_one, name: KeyValue.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def create_maps() do
    1..20
    |> Enum.each(fn num -> KeyValue.Cache.server_process("map #{num}") end)
  end
end
