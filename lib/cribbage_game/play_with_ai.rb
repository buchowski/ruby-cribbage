require "openai"

client = OpenAI::Client.new(
  access_token: ENV.fetch("OPENAI_API_KEY"),
  log_errors: true
)

response = client.chat(
  parameters: {
    model: "gpt-5-nano",
    messages: [{role: "user", content: "Hello can you hear me?"}]
  }
)

puts "start"
puts response.dig("choices", 0, "message", "content")
puts "end\n"
