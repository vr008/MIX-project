#import Config
#config :iex, default_prompt: ">>>"
#config :kv, :routing_table, [{?a..?z, node()}]
import Config

config :kv, :routing_table, [{?a..?z, node()}]

if config_env() == :prod do
  config :kv, :routing_table, [
    {?a..?m, :"foo@vignesh-ThinkPad-E16-Gen-2"},
    {?n..?z, :"bar@Vignesh-ThinkPad-E16-Gen-2"}
  ]
end
