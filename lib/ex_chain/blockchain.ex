defmodule ExChain.Blockchain do
  @moduledoc """
  This module contains the blockchain related functions
  """
  alias __MODULE__
  alias ExChain.Block

  defstruct ~w(chain)a

  @type t :: %Blockchain{
    chain: [Block.t({})]
  }

  @spec new :: Blockchain.t()
  def new() do
    %__MODULE__{}
    |> add_genesis()
  end

  @spec add_block(BlockChain.t(), any) :: BlockChain.t()
  def add_block(blockchain = %__MODULE__{chain: chain}, data) do
    %Block{hash: last_hash} = List.last(chain)

    %{blockchain | chain: chain ++ [Block.mine_block(last_hash, data)]}
  end

  @spec valid_chain?(Blockchain.t()) :: boolean()
  def valid_chain?(%__MODULE__{chain: chain}) do
    chain
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.all?(fn [prev_block, block] ->
      valid_previous_hash?(prev_block, block) && valid_block_hash?(block)
    end)
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

  defp add_genesis(blockchain = %__MODULE__{}) do
    %{blockchain | chain: [Block.genesis()]}
  end
end
