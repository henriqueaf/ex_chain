defmodule ExChain.Blockchain.BlockTest do
  use ExUnit.Case, async: true
  alias ExChain.Blockchain.Block
  doctest Block

  describe "ExChain.Blockchain.Block" do
    test "genesis/0 returns the genesis block" do
      assert %Block{
        timestamp: 1_625_596_693_967,
        previous_hash: "0000000000000000000000000000000000000000000000000000000000000000",
        hash: "652CF9ED5D8E36332062EBFF76B25ECE0D3D42A6E27D493FD5FE0DA27FA7F7ED",
        data: "genesis data",
        nonce: 0
      } == Block.genesis()
    end

    test "mine/4 returns new mined block with previous_hash" do
      %Block{hash: genesis_hash} = Block.genesis()

      assert %Block{
        timestamp: 1_625_596_693_967,
        previous_hash: ^genesis_hash,
        hash: hash,
        data: "some data",
        nonce: 0
      } = Block.mine(timestamp: 1_625_596_693_967, previous_hash: genesis_hash, data: "some data", difficulty: 0)

      assert String.length(hash) == 64
    end

    test "generate_hash/4 returns the block hash" do
      previous_hash = "random_previous_block_hash"
      data = "some block data"

      block = Block.mine(timestamp: 1_625_596_693_967, previous_hash: previous_hash, data: data, difficulty: 0)
      assert block.hash == Block.generate_hash(
        timestamp: block.timestamp,
        previous_hash: previous_hash,
        data: data,
        nonce: 0
      )
    end
  end
end
