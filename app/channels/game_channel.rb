class GameChannel < ApplicationCable::Channel
  def subscribed
    # observer = Observer.first
    stream_from 'game'
    # stream_from "some_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    Character.first.look
  end
end
