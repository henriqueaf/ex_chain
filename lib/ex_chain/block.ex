defmodule ExChain.Block do
  @moduledoc """
  This module represents a Block in a Blockchain service
  """

  alias __MODULE__

  @type t :: %Block{
    index: non_neg_integer(),
    timestamp: pos_integer(),
    previous_hash: String.t(),
    hash: String.t(),
    data: any(),
    nonce: non_neg_integer(),
  }

  defstruct ~w(index timestamp previous_hash hash data nonce)a

  @doc """
  Create a new Genesis Block, that is the first block on Blockchain.

  ## Examples
    iex> ExChain.Block.genesis()
    %ExChain.Block{
      index: 0,
      timestamp: 1625596693967,
      previous_hash: "0000000000000000000000000000000000000000000000000000000000000000",
      data: "genesis data",
      nonce: 0,
      hash: "BD1B8342681227DB6B4A35C52A1047FE4E3261B3942D5EFC42D3431EED75505E"
    }
  """
  @spec genesis() :: Block.t()
  def genesis() do
    new(0, 1_625_596_693_967, String.duplicate("0", 64), "genesis data", 0)
  end

  @doc """
  Mine a new Block (generates a new Block to be added on Blockchain).

  ## Parameters
    - previous_hash: String that represents the previous block hash.
    - index: Integer that represents block position on chain. Starts on 0 (genesis block).
    - data: Data to be save on block.
    - difficulty: The Proof-of-Work difficulty.

  ## Examples
    iex> block = ExChain.Block.mine(previous_hash: "some_previous_block_hash", index: 1, data: "some data", difficulty: 0)
    iex> %ExChain.Block{
    ...>  index: 1,
    ...>  timestamp: _timestamp,
    ...>  previous_hash: "some_previous_block_hash",
    ...>  data: "some data",
    ...>  nonce: 0,
    ...>  hash: _hash
    ...>} = block
  """
  @spec mine(previous_hash: String.t(), index: non_neg_integer(), data: any(), difficulty: non_neg_integer()) :: Block.t()
  def mine(previous_hash: previous_hash, index: index, data: data, difficulty: difficulty) do
    timestamp = get_timestamp()
    proof_of_work(index, timestamp, previous_hash, data, 0, difficulty)
  end

  @spec proof_of_work(non_neg_integer(), non_neg_integer(), String.t(), any(), non_neg_integer(), non_neg_integer()) :: Block.t()
  defp proof_of_work(index, timestamp, previous_hash, data, nonce, difficulty) do
    block = new(index, timestamp, previous_hash, data, nonce)
    zeros = String.duplicate("0", difficulty)

    case block.hash do
      << first_digits::binary-size(difficulty), _rest::binary >> when first_digits == zeros ->
        block
      _ ->
        proof_of_work(index, timestamp, previous_hash, data, nonce + 1, difficulty)
    end
  end

  @doc """
  Generates a hash(sha256) for a Block based on params.

  ## Parameters
    - index: Integer that represents block position on chain. Starts on 0 (genesis block).
    - timestamp: Integer that represents Block datetime as seconds since 1970-01-01T00:00 UTC.
    - previous_hash: String that represents the previous block hash.
    - data: Data to be save on block.
    - nonce: A number to help on Proof-of-Work algorithm

  ## Examples
    iex> ExChain.Block.generate_hash(
    ...>   index: 11,
    ...>   timestamp: 1625596693967,
    ...>   previous_hash: "D35A9D2B7EEE457D9A174D93E4A541CEDCF8D3FFAAD77CA11A6AD18C2793823F",
    ...>   data: "some data",
    ...>   nonce: 123,
    ...> )
    "634A603DA2E5F95EBC84952EA14AA7C202DF7FAB5BC872160B1A639EC5443E49"
  """
  @spec generate_hash(index: non_neg_integer(), timestamp: pos_integer(), previous_hash: String.t(), data: any(), nonce: non_neg_integer()) :: String.t()
  def generate_hash(index: index, timestamp: timestamp, previous_hash: previous_hash, data: data, nonce: nonce) do
    unencrypted_data = "#{index}:#{timestamp}:#{previous_hash}:#{Jason.encode!(data)}:#{nonce}"
    Base.encode16(:crypto.hash(:sha256, unencrypted_data))
  end

  @spec new(non_neg_integer(), pos_integer(), String.t(), any(), non_neg_integer()) :: Block.t()
  defp new(index, timestamp, previous_hash, data, nonce) do
    %__MODULE__{
      index: index,
      timestamp: timestamp,
      previous_hash: previous_hash,
      data: data,
      nonce: nonce,
      hash: generate_hash(index: index, timestamp: timestamp, previous_hash: previous_hash, data: data, nonce: nonce)
    }
  end

  defp get_timestamp(), do: DateTime.utc_now() |> DateTime.to_unix(:millisecond)
end
