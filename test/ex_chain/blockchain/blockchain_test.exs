defmodule ExChain.BlockchainTest do
  use ExUnit.Case
  alias ExChain.Blockchain
  alias ExChain.Block

  describe "ExChain.Blockchain" do
    setup(context) do
      {:ok, Map.put(context, :blockchain, Blockchain.new())}
    end

    test "should start with the genesis block", %{blockchain: blockchain} do
      assert %Block{
        data: "genesis data",
        hash: _hash,
        previous_hash: "-",
        timestamp: _timestamp
      } = hd(blockchain.chain)
    end

    test "adds a new block", %{blockchain: blockchain} do
      data = "foo"
      blockchain = Blockchain.add_block(blockchain, data)
      [_, block] = blockchain.chain
      assert block.data == data
    end

    test "validate a chain", %{blockchain: blockchain} do
      blockchain = Blockchain.add_block(blockchain, "some-block-data")

      assert Blockchain.valid_chain?(blockchain)
    end

    test "should refute when temper data in existing chain", %{
      blockchain: blockchain
    } do
      blockchain =
        blockchain
        |> Blockchain.add_block("blockchain-data-block-1")
        |> Blockchain.add_block("blockchain-data-block-2")
        |> Blockchain.add_block("blockchain-data-block-3")

      assert Blockchain.valid_chain?(blockchain)

      index = 2
      tempered_block = put_in(Enum.at(blockchain.chain, index).data, "tempered_data")

      blockchain = %Blockchain{chain: List.replace_at(blockchain.chain, index, tempered_block)}

      refute Blockchain.valid_chain?(blockchain)
    end
  end
end
