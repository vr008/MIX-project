defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    _ = start_supervised!({KV.Registry, name: context.test})
    %{registry: context.test}
  end

  test "spawns buckets", %{registry: registry} do
    assert KV.Registry.get(registry, "team") == :error

    KV.Registry.post(registry,"team")
    assert {:ok, bucket} = KV.Registry.get(registry,"team")
    KV.Bucket.put(bucket, "bears", [534,2308])
    assert KV.Bucket.get(bucket, "bears") == [534,2308]
  end
  test "removes buckets on exit", %{registry: registry} do
    KV.Registry.post(registry,"team")
    {:ok, bucket} = KV.Registry.get(registry,"team")
    Agent.stop(bucket)
    _ = KV.Registry.post(registry, "bogus")
    assert KV.Registry.get(registry, "team") == :error
  end
  test "removes bucket on crash", %{registry: registry} do
    KV.Registry.post(registry, "team")
    {:ok, bucket} = KV.Registry.get(registry, "team")


    Agent.stop(bucket, :shutdown)

    _ = KV.Registry.post(registry, "bogus")
    assert KV.Registry.get(registry, "team") == :error
  end

end
