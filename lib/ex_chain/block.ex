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

  @spec new(index: non_neg_integer(), timestamp: pos_integer(), previous_hash: String.t(), data: any()) :: Block.t()
  def new(index: index, timestamp: timestamp, previous_hash: previous_hash, data: data) do
    %__MODULE__{}
    |> add_index(index)
    |> add_timestamp(timestamp)
    |> add_previous_hash(previous_hash)
    |> add_data(data)
    |> add_hash()
  end

  @spec genesis() :: Block.t()
  def genesis() do
    __MODULE__.new(index: 0, timestamp: 1_625_596_693_967, previous_hash: String.duplicate("0", 64), data: "genesis data")
  end

  @spec mine(String.t(), non_neg_integer(), any()) :: Block.t()
  def mine(previous_hash, index, data) do
    __MODULE__.new(index: index, timestamp: get_timestamp(), previous_hash: previous_hash, data: data)
  end

  @spec block_hash(Block.t()) :: String.t()
  def block_hash(%__MODULE__{index: index, timestamp: timestamp, previous_hash: previous_hash, data: data}) do
    generate_hash(index, timestamp, previous_hash, data)
  end

  # private functions
  defp add_index(%__MODULE__{} = block, index), do: %{block | index: index}
  defp add_timestamp(%__MODULE__{} = block, timestamp), do: %{block | timestamp: timestamp}
  defp add_previous_hash(%__MODULE__{} = block, previous_hash), do: %{block | previous_hash: previous_hash}
  defp add_data(%__MODULE__{} = block, data), do: %{block | data: data}
  defp add_hash(%__MODULE__{index: index, timestamp: timestamp, previous_hash: previous_hash, data: data} = block) do
    %{block | hash: generate_hash(index, timestamp, previous_hash, data)}
  end

  defp get_timestamp(), do: DateTime.utc_now() |> DateTime.to_unix(:millisecond)

  defp generate_hash(index, timestamp, previous_hash, data) do
    unencrypted_data = "#{index}:#{timestamp}:#{previous_hash}:#{Jason.encode!(data)}"
    Base.encode16(:crypto.hash(:sha256, unencrypted_data))
  end
end
