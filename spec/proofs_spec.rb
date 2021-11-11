require 'spec_helper'

describe TonSdk::Proofs do
  def load_json(file_name)
    JSON.parse(File.read("#{TESTS_DATA_DIR}/proofs/#{file_name}.json"))
  end

  let(:test_client) do
    TestClient.new(
      config: {
        network: TonSdk::NetworkConfig.new(
          endpoints: ["main.ton.dev"]
        )
      }
    )
  end

  it "proof_block_data_test" do
    block_json = load_json("block")
    response = test_client.request(
      "proofs.proof_block_data",
      TonSdk::Proofs::ParamsOfProofBlockData.new(
        block: block_json
      )
    )

    expect(response).to eq(nil)

    response = test_client.request(
      "proofs.proof_block_data",
      TonSdk::Proofs::ParamsOfProofBlockData.new(
        block: nil
      )
    )

    expect(response).to eq("Invalid data: Block's BOC or id are required")

    block_json["id"] = "8ade590a572437332977e68bace66fa00f9cebac6baa57f6bf2d2f1276db2848"
    response = test_client.request(
      "proofs.proof_block_data",
      TonSdk::Proofs::ParamsOfProofBlockData.new(
        block: block_json
      )
    )

    puts response.class

    expect(response).to eq('Data differs from the proven: field `blocks.id`: expected String("8bde590a572437332977e68bace66fa00f9cebac6baa57f6bf2d2f1276db2848"), actual String("8ade590a572437332977e68bace66fa00f9cebac6baa57f6bf2d2f1276db2848")')
  end

  it "proof_transaction_data_test" do
    transaction_json = load_json("transaction")
    response = test_client.request(
      "proofs.proof_transaction_data",
      TonSdk::Proofs::ParamsOfProofTransactionData.new(
        transaction: transaction_json
      )
    )

    expect(response).to eq(nil)

    response = test_client.request(
      "proofs.proof_transaction_data",
      TonSdk::Proofs::ParamsOfProofTransactionData.new(
        transaction: nil
      )
    )

    expect(response).to eq("Invalid data: Transaction's BOC or id are required")

    transaction_json["id"] = "1c7e395e8eb14c173d2dde7189200f28787a05df1fa188b19224f6e19a439dc6"
    response = test_client.request(
      "proofs.proof_transaction_data",
      TonSdk::Proofs::ParamsOfProofTransactionData.new(
        transaction: transaction_json
      )
    )

    expect(response).to eq('Data differs from the proven: field `transactions.id`: expected String("0c7e395e8eb14c173d2dde7189200f28787a05df1fa188b19224f6e19a439dc6"), actual String("1c7e395e8eb14c173d2dde7189200f28787a05df1fa188b19224f6e19a439dc6")')
  end
end
