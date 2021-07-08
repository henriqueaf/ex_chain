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
    data: any()
  }

  defstruct ~w(index timestamp previous_hash hash data)a

  @doc """
  Create a new Block with the given parameters and generate the block hash.

  ## Parameters
    - index: Integer that represents block position on chain. Starts on 0 (genesis block).
    - timestamp: Integer that represents Block datetime as seconds since 1970-01-01T00:00 UTC.
    - previous_hash: String that represents the previous block hash.
    - data: Data to be save on block.

  ## Examples
    iex> ExChain.Block.new(index: 1, timestamp: 1_625_596_693_967, previous_hash: "some_previous_block_hash", data: "some data")
    %ExChain.Block{
      index: 1,
      timestamp: 1625596693967,
      previous_hash: "some_previous_block_hash",
      data: "some data",
      hash: "469BBBCF3E8CB50202C896298F1EF91C9F23A5A7863D932E0DD0C7A8864E41B9"
    }
  """
  @spec new(index: non_neg_integer(), timestamp: pos_integer(), previous_hash: String.t(), data: any()) :: Block.t()
  def new(index: index, timestamp: timestamp, previous_hash: previous_hash, data: data) do
    %__MODULE__{
      index: index,
      timestamp: timestamp,
      previous_hash: previous_hash,
      data: data,
      hash: generate_hash(index, timestamp, previous_hash, data)
    }
  end

  @doc """
  Create a new Genesis Block, that is the first block on Blockchain.

  ## Examples
    iex> ExChain.Block.genesis()
    %ExChain.Block{
      index: 0,
      timestamp: 1625596693967,
      previous_hash: "0000000000000000000000000000000000000000000000000000000000000000",
      data: "genesis data",
      hash: "D35A9D2B7EEE457D9A174D93E4A541CEDCF8D3FFAAD77CA11A6AD18C2793823F"
    }
  """
  @spec genesis() :: Block.t()
  def genesis() do
    new(index: 0, timestamp: 1_625_596_693_967, previous_hash: String.duplicate("0", 64), data: "genesis data")
  end

  @doc """
  Mine a new Block (generates a new Block to be added on Blockchain).

  ## Parameters
    - previous_hash: String that represents the previous block hash.
    - index: Integer that represents block position on chain. Starts on 0 (genesis block).
    - data: Data to be save on block.

  ## Examples
    iex> block = ExChain.Block.mine("some_previous_block_hash", 1, "some data")
    iex> %ExChain.Block{
    ...>  index: 1,
    ...>  timestamp: _timestamp,
    ...>  previous_hash: "some_previous_block_hash",
    ...>  data: "some data",
    ...>  hash: _hash
    ...>} = block
  """
  @spec mine(String.t(), non_neg_integer(), any()) :: Block.t()
  def mine(previous_hash, index, data) do
    new(index: index, timestamp: get_timestamp(), previous_hash: previous_hash, data: data)
  end

  @doc """
  Generates a hash(sha256) for a Block based on params.

  ## Parameters
    - index: Integer that represents block position on chain. Starts on 0 (genesis block).
    - timestamp: Integer that represents Block datetime as seconds since 1970-01-01T00:00 UTC.
    - previous_hash: String that represents the previous block hash.
    - data: Data to be save on block.

  ## Examples
    iex> ExChain.Block.generate_hash(11, 1625596693967, "D35A9D2B7EEE457D9A174D93E4A541CEDCF8D3FFAAD77CA11A6AD18C2793823F", "some data")
    "A7E15638FCEDA1DDC8737DC647FC25B9B916DEA90EED6B86B6B4A205C39B212D"
  """
  @spec generate_hash(non_neg_integer(), pos_integer(), String.t(), any()) :: String.t()
  def generate_hash(index, timestamp, previous_hash, data) do
    unencrypted_data = "#{index}:#{timestamp}:#{previous_hash}:#{Jason.encode!(data)}"
    Base.encode16(:crypto.hash(:sha256, unencrypted_data))
  end

  defp get_timestamp(), do: DateTime.utc_now() |> DateTime.to_unix(:millisecond)
end
