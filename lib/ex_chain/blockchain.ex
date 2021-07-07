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

  @spec new :: Blockchain.t()
  def new() do
    %__MODULE__{}
    |> add_genesis_block()
  end

  @spec add_block(Blockchain.t(), any) :: Blockchain.t()
  def add_block(blockchain = %__MODULE__{chain: chain}, data) do
    %Block{hash: last_hash} = List.last(chain)
    index = length(chain)

    %{blockchain | chain: chain ++ [Block.mine(last_hash, index, data)]}
  end

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
    block.hash == Block.block_hash(block)
  end

  defp add_genesis_block(blockchain = %__MODULE__{}) do
    %{blockchain | chain: [Block.genesis()]}
  end
end
