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
  end

  def unsubscribed
  end

  def receive(data)
    session_broadcast "Received message: #{data["body"]}"
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
    if(@current_account.present? && @current_account.commander.present?)
      @current_account.commander.process(message.shift, message)
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
    else
      @current_account = result.first
      session_broadcast "Logged in as #{@current_account.name}"
      return
    end
  end

  def logout(trash=nil)
    if(@current_account.blank?)
      session_broadcast "Not logged in"
    else
      @current_account = nil
      session_broadcast "Logged out"
    end
  end

  def register(messages)
    account = Account.create(name: messages.first)
    if(account.errors.present?)
      session_broadcast "No."
    else
      @current_account = account
      session_broadcast "New account created: #{@current_account.name}"
    end
  end

  def status(trash)
    if(@current_account.blank?)
      session_broadcast "Not logged in."
    else
      session_broadcast "Logged in as #{@current_account.name}. Commanders are #{@current_account.commanders}. Observer is #{@current_account.observer}. Characters are #{@current_account.characters}"
    end
  end
end
