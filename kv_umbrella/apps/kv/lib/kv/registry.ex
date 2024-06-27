
defmodule KV.Registry do
  use GenServer


  @impl true
  def init(table) do
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:create, tname}, _from, {names, refs}) do
    case get(names, tname) do
      {:ok, pid} ->
        {:reply, pid, {names, refs}}

      :error ->
        {:ok, pid} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, tname)
        :ets.insert(names, {tname, pid})
        {:reply,pid, {names, refs}}

        end
    end


  @doc """
  @impl true

   def handle_cast({:create,tname,style}, {names ,refs}) do
    case get(names,style, tname) do
      {:ok, _pid} ->
        {:noreply, {names, refs}}
      :error ->
      {:ok, pid} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, tname)
      :ets.insert(names, {tname, pid})

      if style=="offence" do
        {:noreply, {names, refs}}
      else
        {:noreply,{"style not found",refs}}
      end
    end
  end
  """
  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

def start_link(opts) do
  server = Keyword.fetch!(opts, :name)
  GenServer.start_link(__MODULE__, server, opts)

end


def get(server, tname)do
  case :ets.lookup(server, tname) do

    [{^tname, pid}] -> {:ok, pid}

    [] -> :error


end
end



def post(server,tname) do
  GenServer.call(server, {:create, tname})
end


end
