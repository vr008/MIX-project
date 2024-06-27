defmodule KVServer.Command do
  def parse(line) do
    case String.split(line) do
      ["POST", bucket] -> {:ok, {:post, bucket}}
      ["PUT", bucket,key,value] -> {:ok, {:put, bucket,key,value}}
      ["GET", bucket,key] -> {:ok, {:get, bucket,key}}
      ["DELETE", bucket, key] -> {:ok, {:delete, bucket, key}}

      _ -> {:error, :unknown_command}
    end
  end


@doc"""
  def run({:post, bucket}, pid) do
    KV.Registry.post(pid, bucket)
    {:ok, "OK\r\n"}
  end
"""
def run({:create, bucket}) do
  case KV.Router.route(bucket, KV.Registry, :create, [KV.Registry, bucket]) do
    pid when is_pid(pid) -> {:ok, "OK\r\n"}
    _ -> {:error, "FAILED TO CREATE BUCKET"}
  end
end
  def run({:post, bucket}) do
    KV.Registry.post(KV.Registry, bucket)
    {:ok, "OK\r\n"}
  end

  def run({:get, bucket,key}) do
    lookup(bucket, fn pid ->
      value = KV.Bucket.get(pid, key)
      {:ok, "#{value}\r\n"}
    end)
  end

  def run({:put, bucket,key, value}) do
    lookup(bucket, fn pid ->
      KV.Bucket.put(pid, key,value)
      {:ok, "OK\r\n"}
    end)
  end

  def run({:delete, bucket, key}) do
    lookup(bucket, fn pid ->
      KV.Bucket.delete(pid,key)
      {:ok, "OK\r\n"}
    end)
  end

  defp lookup(bucket, callback) do
    case KV.Registry.get(KV.Registry, bucket) do
      {:ok, pid} -> callback.(pid)
      :error -> {:error, :not_found}
    end
  end
end
