defmodule KV.BucketTest do
  use ExUnit.Case, async: true
  setup do
    {:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

  test "stores values by key" do
    {:ok, bucket} = KV.Bucket.start_link([])
    assert KV.Bucket.get(bucket, "bears") == nil

    KV.Bucket.put(bucket, "bears",[534,2308] )
    assert KV.Bucket.get(bucket, "bears") == [534,2308]
  end
  test "are temporary workers" do
    assert Supervisor.child_spec(KV.Bucket, []).restart == :temporary
  end
end
