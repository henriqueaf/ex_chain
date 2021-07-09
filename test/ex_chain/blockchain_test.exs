defmodule ExChain.BlockchainTest do
  use ExUnit.Case, async: true
  alias ExChain.{Block, Blockchain}
  doctest Blockchain

  describe "ExChain.Blockchain" do
    setup(context) do
      {:ok, Map.put(context, :blockchain, Blockchain.new(0))}
    end

    test "new/0 should start with the genesis block" do
      %Blockchain{chain: [blockchain_genesis]} = Blockchain.new(0)

      assert blockchain_genesis == Block.genesis()
    end

    test "add_block/2 adds a new block to chain", %{blockchain: blockchain} do
      data = "foo"
      block =
        blockchain
        |> Blockchain.add_block(data)
        |> Map.get(:chain)
        |> List.last

      assert block.data == data
    end

    test "valid_chain/1 validate a chain", %{blockchain: blockchain} do
      blockchain =
        blockchain
        |> Blockchain.add_block("some-block-data-1")
        |> Blockchain.add_block("some-block-data-2")

      %Block{hash: genesis_hash} = genesis_block = Block.genesis()

      assert [
        ^genesis_block,
        %Block{
          timestamp: _,
          previous_hash: ^genesis_hash,
          hash: _,
          data: "some-block-data-1",
          nonce: _,
        },
        %Block{
          timestamp: _,
          previous_hash: _,
          hash: _,
          data: "some-block-data-2",
          nonce: _,
        }
      ] = blockchain.chain

      assert Blockchain.valid_chain?(blockchain)
    end

    test "valid_chain/1 should refute when temper data in existing chain", %{blockchain: blockchain} do
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
