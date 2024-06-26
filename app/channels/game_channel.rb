class GameChannel < ApplicationCable::Channel
  def connect
    @current_account = nil
  end

  def connection_channel
    @connection_channel ||= "session-#{connection.session.id}"
  end

  def subscribed
    stream_from connection_channel
    session_broadcast "Welcome, user #{connection.session.id}!"
    update_status
  end

  def unsubscribed
  end

  def receive(data)
    Rails.logger.info "Received message: #{data}"
    message = data["body"].split(" ")
    
    if message.empty?
      session_broadcast "Nothing submitted."
      return
    end

    # Session commands, for logging into and out of accounts
    if(command_list.keys.include?(message.first))
      self.send(command_list[message.shift][:method], message)
      return
    end

    # Pass any other commands to the account
    if(@current_account.present? && @current_account.commanders.present?)
      # TODO: Be able to target which commander to send this to
      @current_account.commanders.first.process(message.shift, message)
      return
    end

    session_broadcast "Command not recognized."
  end

  # Top level game commands for users that are not logged in
  def session_broadcast(value)
    ActionCable.server.broadcast(connection_channel, {action: "display", messages: [value]})
  end

  def command_list
    @command_list ||={
      "login" => {
        id: "login",
        method: :login
      },
      "logout" => {
        id: "logout",
        method: :logout
      },
      "register" => {
        id: "register",
        method: :register
      },
      "status" => {
        id: "status",
        method: :status
      }
    }
  end

  def login(messages)
    name = messages.shift

    if(@current_account.present?)
      session_broadcast "Already logged in."
      return
    end

    if(name.blank?)
      session_broadcast "Login requires a login name"
      return
    end
    
    result = Account.where(name: name)
    if(result.blank?)
      session_broadcast "Account not found"
      return
    end

    # LOGIN
    @current_account = result.first
    stream_from @current_account.observer.channel_id
    session_broadcast "Logged in as #{@current_account.name}"
    update_status
    return
  end

  def logout(trash=nil)
    if(@current_account.blank?)
      session_broadcast "Not logged in"
    else # LOGOUT
      stop_stream_from @current_account.observer.channel_id
      @current_account = nil
      session_broadcast "Logged out"
      update_status
    end
  end

  def register(messages)
    account = Account.create(name: messages.first)
    if(account.errors.present?)
      session_broadcast "No."
    else
      session_broadcast "New account created: #{account.name}"
    end
  end

  def status(trash)
    if(@current_account.blank?)
      session_broadcast "Not logged in."
    else
      session_broadcast "Logged in as #{@current_account.name}. Commanders are #{@current_account.commanders}. Observer is #{@current_account.observer}. Characters are #{@current_account.characters}"
    end
  end

  def update_status
    if(@current_account.present?)
      ActionCable.server.broadcast(connection_channel, {action: "status-update", account_name: @current_account.name, character_name: @current_account.characters.first.name})
    else
      ActionCable.server.broadcast(connection_channel, {action: "status-update", account_name: "Not logged in.", character_name: "No character selected."})
    end
  end
end
