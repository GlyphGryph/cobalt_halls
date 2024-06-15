class GameChannel < ApplicationCable::Channel
  def subscribed
    @observer = Observer.first || Observer.create
    @commander = Commander.first || Commander.create!(subordinate: Character.first)
    stream_from 'game'
    # stream_from "some_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    message = data["body"].split(" ")
    @commander.process(message.shift, message)
  end
end
