defmodule ExChain.BlockTest do
  use ExUnit.Case, async: true
  alias ExChain.Block
  doctest Block

  describe "ExChain.Block" do
    test "genesis/0 returns the genesis block" do
      assert %Block{
        index: 0,
        timestamp: 1_625_596_693_967,
        previous_hash: "0000000000000000000000000000000000000000000000000000000000000000",
        hash: "D35A9D2B7EEE457D9A174D93E4A541CEDCF8D3FFAAD77CA11A6AD18C2793823F",
        data: "genesis data"
      } == Block.genesis()
    end

    test "mine/3 returns new mined block with previous_hash" do
      %Block{hash: genesis_hash} = Block.genesis()
      index = 1

      assert %Block{
        index: ^index,
        timestamp: timestamp,
        previous_hash: ^genesis_hash,
        hash: hash,
        data: "some data"
      } = Block.mine(previous_hash: genesis_hash, index: index, data: "some data")

      assert String.length(hash) == 64

      current_timestamp = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
      assert current_timestamp > timestamp
    end

    test "generate_hash/1 returns the block hash" do
      index = 1
      previous_hash = "random_previous_block_hash"
      data = "some block data"

      block = Block.mine(previous_hash: previous_hash, index: index, data: data)
      assert block.hash == Block.generate_hash(
        index: index,
        timestamp: block.timestamp,
        previous_hash: previous_hash,
        data: data
      )
    end
  end
end
