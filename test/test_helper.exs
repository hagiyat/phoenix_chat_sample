ExUnit.start

Mix.Task.run "ecto.create", ~w(-r ChatSample.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r ChatSample.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(ChatSample.Repo)

