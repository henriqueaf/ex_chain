defmodule ExChain.Blockchain do
  @moduledoc """
  This module contains the blockchain related functions
  """
  alias __MODULE__
  alias ExChain.Block

  defstruct ~w(chain)a

  @type t :: %Blockchain{
    chain: [Block.t()]
  }

  @doc """
  Create a new Blockchain with a Genesis Block on it's chain.

  ## Examples
    iex> ExChain.Blockchain.new()
    %ExChain.Blockchain{
      chain: [ExChain.Block.genesis()]
    }
  """
  @spec new :: Blockchain.t()
  def new() do
    %__MODULE__{
      chain: [Block.genesis()]
    }
  end

  @doc """
  Add a new block to chain with the given data.

  ## Parameters
    - blockchain: The Blockchain that Block will enter.
    - data: The data that will go into the Block.

  ## Examples
    iex> blockchain = ExChain.Blockchain.new()
    iex> %ExChain.Blockchain{chain: [_genesis_block, added_block]} = ExChain.Blockchain.add_block(blockchain, "some data")
    iex> %ExChain.Block{
    ...>  index: 1,
    ...>  timestamp: _timestamp,
    ...>  previous_hash: _genesis_block_hash,
    ...>  data: "some data",
    ...>  hash: _hash
    ...>} = added_block
  """
  @spec add_block(Blockchain.t(), any) :: Blockchain.t()
  def add_block(blockchain = %__MODULE__{chain: chain}, data) do
    %Block{hash: last_hash} = List.last(chain)
    index = length(chain)

    %{blockchain | chain: chain ++ [Block.mine(previous_hash: last_hash, index: index, data: data)]}
  end

  @doc """
  Checks if the Blockchain has a valid chain structure.

  ## Parameters
    - blockchain: The Blockchain to be validated.

  ## Examples
    iex> blockchain = ExChain.Blockchain.new()
    iex> ExChain.Blockchain.valid_chain?(blockchain)
    true
  """
  @spec valid_chain?(Blockchain.t()) :: boolean()
  def valid_chain?(%__MODULE__{chain: chain}) do
    chain
    |> Stream.chunk_every(2, 1, :discard)
    |> Enum.all?(fn [prev_block, block] ->
      valid_indexes?(prev_block, block) && valid_previous_hash?(prev_block, block) && valid_block_hash?(block)
    end)
  end

  defp valid_indexes?(
    %Block{index: previous_index} = _previous_block,
    %Block{index: current_index} = _current_block
  ) do
    current_index == previous_index + 1
  end

  defp valid_previous_hash?(
    %Block{hash: hash} = _previous_block,
    %Block{previous_hash: previous_hash} = _current_block
  ) do
    hash == previous_hash
  end

  defp valid_block_hash?(block) do
    block.hash == Block.generate_hash(
      index: block.index,
      timestamp: block.timestamp,
      previous_hash: block.previous_hash,
      data: block.data
    )
  end
end
