defmodule FileTarget do
  @moduledoc """
  Documentation for `FileTarget`.
  """

  use GenServer
  require Logger

  @behaviour Core.TargetContract

  def start_link(file_path) do
    GenServer.start_link(__MODULE__, file_path, name: __MODULE__)
  end

  @impl Core.TargetContract
  def handle_message(message) do
    GenServer.cast(__MODULE__, {:replication_message, message})
  end

  @impl true
  def init(file_path) do
    {:ok, file} = File.open(file_path, [:append])
    {:ok, %{file: file}}
  end

  @impl true
  def handle_cast({:replication_message, message}, state) do
    serialized = serialize(message)
    IO.write(state.file, serialized <> "\n")
    Logger.debug("Wrote message to file: #{inspect(message)}")
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, %{file: file}) do
    File.close(file)
    :ok
  end

  defp serialize(message) do
    inspect(message)
  end
end
