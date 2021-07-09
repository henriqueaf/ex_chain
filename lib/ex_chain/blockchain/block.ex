defmodule ExChain.Blockchain.Block do
  @moduledoc """
  This module represents a Block in a Blockchain service
  """

  alias __MODULE__

  @type t :: %Block{
    timestamp: pos_integer(),
    previous_hash: String.t(),
    hash: String.t(),
    data: any(),
    nonce: non_neg_integer(),
  }

  defstruct ~w(timestamp previous_hash hash data nonce)a

  @doc """
  Create a new Genesis Block, that is the first block on Blockchain.

  ## Examples
    iex> ExChain.Blockchain.Block.genesis()
    %ExChain.Blockchain.Block{
      timestamp: 1625596693967,
      previous_hash: "0000000000000000000000000000000000000000000000000000000000000000",
      data: "genesis data",
      nonce: 0,
      hash: "652CF9ED5D8E36332062EBFF76B25ECE0D3D42A6E27D493FD5FE0DA27FA7F7ED"
    }
  """
  @spec genesis() :: Block.t()
  def genesis() do
    new(1_625_596_693_967, String.duplicate("0", 64), "genesis data", 0)
  end

  @doc """
  Mine a new Block (generates a new Block to be added on Blockchain).

  ## Parameters
    - timestamp: Integer that represents Block datetime as seconds since 1970-01-01T00:00 UTC.
    - previous_hash: String that represents the previous block hash.
    - data: Data to be save on block.
    - difficulty: The Proof-of-Work difficulty.

  ## Examples
    iex> block = ExChain.Blockchain.Block.mine(timestamp: 1_625_596_693_967, previous_hash: "some_previous_block_hash", data: "some data", difficulty: 0)
    iex> %ExChain.Blockchain.Block{
    ...>  timestamp: 1_625_596_693_967,
    ...>  previous_hash: "some_previous_block_hash",
    ...>  data: "some data",
    ...>  nonce: 0,
    ...>  hash: _hash
    ...>} = block
  """
  @spec mine(timestamp: pos_integer(), previous_hash: String.t(), data: any(), difficulty: non_neg_integer()) :: Block.t()
  def mine(timestamp: timestamp, previous_hash: previous_hash, data: data, difficulty: difficulty) do
    proof_of_work(timestamp, previous_hash, data, 0, difficulty)
  end

  @spec proof_of_work(non_neg_integer(), String.t(), [any()], non_neg_integer(), non_neg_integer()) :: Block.t()
  defp proof_of_work(timestamp, previous_hash, data, nonce, difficulty) do
    block = new(timestamp, previous_hash, data, nonce)
    zeros = String.duplicate("0", difficulty)

    case block.hash do
      << first_digits::binary-size(difficulty), _rest::binary >> when first_digits == zeros ->
        block
      _ ->
        proof_of_work(timestamp, previous_hash, data, nonce + 1, difficulty)
    end
  end

  @doc """
  Generates a hash(sha256) for a Block based on params.

  ## Parameters
    - timestamp: Integer that represents Block datetime as seconds since 1970-01-01T00:00 UTC.
    - previous_hash: String that represents the previous block hash.
    - data: Data to be save on block.
    - nonce: A number to help on Proof-of-Work algorithm

  ## Examples
    iex> ExChain.Blockchain.Block.generate_hash(
    ...>   timestamp: 1625596693967,
    ...>   previous_hash: "D35A9D2B7EEE457D9A174D93E4A541CEDCF8D3FFAAD77CA11A6AD18C2793823F",
    ...>   data: "some data",
    ...>   nonce: 123,
    ...> )
    "16BFF0FA8912D0A4A798B8264286D59A2D2FDE2A0B4553082890A40A7FA81850"
  """
  @spec generate_hash(timestamp: pos_integer(), previous_hash: String.t(), data: any(), nonce: non_neg_integer()) :: String.t()
  def generate_hash(timestamp: timestamp, previous_hash: previous_hash, data: data, nonce: nonce) do
    unencrypted_data = "#{timestamp}:#{previous_hash}:#{Jason.encode!(data)}:#{nonce}"
    Base.encode16(:crypto.hash(:sha256, unencrypted_data))
  end

  @spec new(pos_integer(), String.t(), any(), non_neg_integer()) :: Block.t()
  defp new(timestamp, previous_hash, data, nonce) do
    %__MODULE__{
      timestamp: timestamp,
      previous_hash: previous_hash,
      data: data,
      nonce: nonce,
      hash: generate_hash(timestamp: timestamp, previous_hash: previous_hash, data: data, nonce: nonce)
    }
  end
end
