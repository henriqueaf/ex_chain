defmodule ExChain.Cryptocurrency.Transaction do
  @moduledoc """
  This module represents a Transaction in a Cryptocurrency service.
  """

  alias __MODULE__

  @type t :: %Transaction{
    from_address: String.t(),
    to_address: String.t(),
    amount: pos_integer()
  }

  defstruct ~w(from_address to_address amount)a
end
