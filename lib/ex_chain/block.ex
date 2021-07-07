defmodule ExChain.Block do
  @moduledoc """
  This module represents a Block in a Blockchain service
  """

  alias __MODULE__

  @type t :: %Block{
    timestamp: pos_integer(),
    previous_hash: String.t(),
    hash: String.t(),
    data: any()
  }

  defstruct ~w(timestamp previous_hash hash data)a

  @spec new(timestamp: pos_integer(), previous_hash: String.t(), data: any()) :: Block.t()
  def new(timestamp: timestamp, previous_hash: previous_hash, data: data) do
    %__MODULE__{}
    |> add_timestamp(timestamp)
    |> add_previous_hash(previous_hash)
    |> add_data(data)
    |> add_hash()
  end

  @spec genesis() :: Block.t()
  def genesis() do
    __MODULE__.new(timestamp: 1_625_596_693_967, previous_hash: "-", data: "genesis data")
  end

  @spec mine_block(String.t(), any()) :: Block.t()
  def mine_block(previous_hash, data) do
    __MODULE__.new(timestamp: get_timestamp(), previous_hash: previous_hash, data: data)
  end

  @spec block_hash(Block.t()) :: String.t()
  def block_hash(%__MODULE__{timestamp: timestamp, previous_hash: previous_hash, data: data}) do
    generate_hash(timestamp, previous_hash, data)
  end

  # private functions
  defp add_timestamp(%__MODULE__{} = block, timestamp), do: %{block | timestamp: timestamp}
  defp add_previous_hash(%__MODULE__{} = block, previous_hash), do: %{block | previous_hash: previous_hash}
  defp add_data(%__MODULE__{} = block, data), do: %{block | data: data}
  defp add_hash(%__MODULE__{timestamp: timestamp, previous_hash: previous_hash, data: data} = block) do
    %{block | hash: generate_hash(timestamp, previous_hash, data)}
  end

  defp get_timestamp(), do: DateTime.utc_now() |> DateTime.to_unix(:millisecond)

  defp generate_hash(timestamp, previous_hash, data) do
    unencrypted_data = "#{timestamp}:#{previous_hash}:#{Jason.encode!(data)}"
    Base.encode16(:crypto.hash(:sha256, unencrypted_data))
  end
end
