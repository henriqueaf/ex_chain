defmodule ExChain.Cryptocurrency do
  @moduledoc """
  This module interact with Blockchain to allow use it as a cryptocurrency.
  """

  alias __MODULE__
  alias ExChain.Blockchain
  alias ExChain.Blockchain.Block
  alias ExChain.Cryptocurrency.Transaction

  defstruct ~w(mining_reward difficulty pending_transactions blockchain)a

  @type t :: %Cryptocurrency{
    mining_reward: pos_integer(),
    difficulty: non_neg_integer(),
    pending_transactions: [Transaction.t()],
    blockchain: Blockchain.t()
  }

  @doc """
  Create a new Cryptocurrency struct with a Blockchain to interact with.

  ## Parameters
    - mining_reward: The amount of coins that miner will receive after mine a Block.

  ## Examples
    iex> cryptocurrency = ExChain.Cryptocurrency.new(100)
    iex> %ExChain.Cryptocurrency{
    ...>   mining_reward: 100,
    ...>   pending_transactions: [],
    ...>   blockchain: %ExChain.Blockchain{}
    ...> } = cryptocurrency
  """
  @spec new(pos_integer(), non_neg_integer()) :: Cryptocurrency.t()
  def new(mining_reward, difficulty) do
    %__MODULE__{
      mining_reward: mining_reward,
      difficulty: difficulty,
      pending_transactions: [],
      blockchain: ExChain.Blockchain.new()
    }
  end

  def mine_pending_transactions(cryptocurrency, mining_reward_address) do
    %Block{hash: last_hash} = List.last(cryptocurrency.blockchain.chain)

    proof_of_work(get_timestamp(), last_hash, cryptocurrency.pending_transactions, 0, cryptocurrency.difficulty)
  end

  @spec proof_of_work(non_neg_integer(), String.t(), any(), non_neg_integer(), non_neg_integer()) :: Block.t()
  defp proof_of_work(timestamp, previous_hash, data, nonce, difficulty) do
    block = Block.new(timestamp, previous_hash, data, nonce)
    zeros = String.duplicate("0", difficulty)

    case block.hash do
      << first_digits::binary-size(difficulty), _rest::binary >> when first_digits == zeros ->
        block
      _ ->
        proof_of_work(timestamp, previous_hash, data, nonce + 1, difficulty)
    end
  end

  defp get_timestamp(), do: DateTime.utc_now() |> DateTime.to_unix(:millisecond)
end
