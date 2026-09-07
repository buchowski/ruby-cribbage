require "stringio"
require "cribbage_game/play_with_ai"

RSpec.describe HumanVsAiRunner do
  class FakeResponsesClient
    attr_reader :requests

    def initialize(responses)
      @responses = responses
      @requests = []
    end

    def responses
      self
    end

    def create(parameters:)
      @requests << parameters
      @responses.shift
    end
  end

  let(:player) { CribbageGame::Game.new.players[1] }
  let(:tool) { HumanVsAiRunner::PLAY_CARD_TOOL }
  let(:responses) do
    [
      {"output" => [{"type" => "function_call", "name" => "play_card", "arguments" => '{"card_id":"bad"}'}]},
      {"output" => [{"type" => "function_call", "name" => "play_card", "arguments" => '{"card_id":"5h"}'}]}
    ]
  end

  def run_tool(runner)
    runner.send(:ai_tool_arguments, player, tool, "Choose a card") do |data|
      data["card_id"] == "5h"
    end
  end

  it "keeps AI input logging disabled by default in the option parser" do
    allow(described_class).to receive(:new).and_return(:runner)

    expect(described_class.from_argv([])).to eql(:runner)
    expect(described_class).to have_received(:new).with(
      name: nil,
      number_of_players: 2,
      points_to_win: 121,
      all_ai: false,
      log_ai_inputs: false
    )
  end

  it "enables AI input logging from the option parser" do
    allow(described_class).to receive(:new).and_return(:runner)

    expect(described_class.from_argv(["--log-ai-inputs"])).to eql(:runner)
    expect(described_class).to have_received(:new).with(
      name: nil,
      number_of_players: 2,
      points_to_win: 121,
      all_ai: false,
      log_ai_inputs: true
    )
  end

  it "enables all-AI mode from the option parser" do
    allow(described_class).to receive(:new).and_return(:runner)

    expect(described_class.from_argv(["--all-ai", "--players", "3"])).to eql(:runner)
    expect(described_class).to have_received(:new).with(
      name: nil,
      number_of_players: 3,
      points_to_win: 121,
      all_ai: true,
      log_ai_inputs: false
    )
  end

  it "sets the points needed to win from the option parser" do
    allow(described_class).to receive(:new).and_return(:runner)

    expect(described_class.from_argv(["--points-to-win", "35"])).to eql(:runner)
    expect(described_class).to have_received(:new).with(
      name: nil,
      number_of_players: 2,
      points_to_win: 35,
      all_ai: false,
      log_ai_inputs: false
    )
  end

  it "uses sequential AI labels in all-AI mode" do
    runner = described_class.new(all_ai: true, client: FakeResponsesClient.new([]))
    game = CribbageGame::Game.new(number_of_players: 3)

    labels = game.players.map { |player| runner.send(:player_label, player) }

    expect(labels).to eql(["AI Player One", "AI Player Two", "AI Player Three"])
  end

  it "does not log AI inputs or failed tools by default" do
    output = StringIO.new
    runner = HumanVsAiRunner.new(client: FakeResponsesClient.new(responses), output: output)

    # "5h" is the 2nd attempt. "bad" is the 1st attempt, which fails but is not logged to output
    expect(run_tool(runner)).to eql({"card_id" => "5h"})
    expect(output.string).to be_empty
  end

  it "logs AI inputs and failed tools when enabled" do
    output = StringIO.new
    runner = HumanVsAiRunner.new(
      client: FakeResponsesClient.new(responses),
      log_ai_inputs: true,
      output: output
    )

    # "5h" is the 2nd attempt. "bad" is the 1st attempt, which fails and is logged to output because log_ai_inputs is true
    expect(run_tool(runner)).to eql({"card_id" => "5h"})
    expect(output.string).to include("AI Player One input: Choose a card")
    expect(output.string).to match(/failed tool play_card with arguments \{\"card_id\"\s*=>\s*\"bad\"\} \(attempt 1\)/)
  end
end
