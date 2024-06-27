defmodule KV.Bucket do
  use Agent, restart: :temporary


  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end



  def get(bucket,tname) do

    Agent.get(bucket, fn arg -> Map.get(arg,tname)end)

  end


  def put(bucket, tname,details) do

    Agent.update(bucket, fn arg -> Map.put(arg,tname,details)end)

  end


  def delete(bucket,tname) do
    Agent.get_and_update(bucket, fn arg -> Map.pop(arg,tname)end)
  end
end
