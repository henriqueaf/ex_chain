defmodule ExChain.BlockTest do
  use ExUnit.Case
  alias ExChain.Block

  describe "ExChain.Block" do
    test "genesis block is valid" do
      assert %Block{
        data: "genesis data",
        hash: "44FB087CBCE03B9AA5253EE140D57BCA37C92C9B3A0112B7892B09997475248B",
        previous_hash: "-",
        timestamp: 1_625_596_693_967
      } == Block.genesis()
    end

    test "mine_block returns new block with previous_hash" do
      %Block{hash: hash} = Block.genesis()

      assert %Block{
        data: "some data",
        previous_hash: ^hash
      } = Block.mine_block(hash, "some data")
    end

    test "return a new block" do
      timestamp = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
      previous_hash = "random_previous_block_hash"
      data = "some block data"

      assert %Block{
        timestamp: ^timestamp,
        hash: _hash,
        previous_hash: ^previous_hash,
        data: ^data
      } = Block.new(timestamp: timestamp, previous_hash: previous_hash, data: data)
    end

    test "return the block hash" do
      timestamp = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
      previous_hash = "random_previous_block_hash"
      data = "some block data"

      block = Block.new(timestamp: timestamp, previous_hash: previous_hash, data: data)
      assert block.hash == Block.block_hash(block)
    end
  end
end
