defmodule UpBot.ReferenceTracker do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(id) do
    Agent.get(__MODULE__, &Map.get(&1, id))
  end

  def put(id, ref) do
    Agent.update(__MODULE__, &Map.put(&1, id, ref))
  end

  def delete(id) do
    Agent.update(__MODULE__, &Map.delete(&1, id))
  end
end
