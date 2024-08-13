class GameChannel < ApplicationCable::Channel
  include Actionable

  def connect
    @current_account = nil
  end

  def connection_channel
    @connection_channel ||= "session-#{connection.session.id}"
  end

  def subscribed
    stream_from connection_channel
    display "Welcome, user #{connection.session.id}!"
    update_status
  end

  def unsubscribed
  end

  def receive(data)
    Rails.logger.info "Received message: #{data}"
    commands = data["body"].split(" ")
    if commands.empty?
      display "Nothing submitted."
      return
    end
    command_processed = self.process_command(commands)
    if(!command_processed)
      display "Command not recognized."
    end
  end

private
  def actionable_action_ids
    @actionable_action_ids ||= [:help, :login, :logout, :register, :status]
  end

  def actionable_children
    children = []
    if @current_account.present?
      children << @current_acount
    end
    return children
  end

  def display(value)
    ActionCable.server.broadcast(connection_channel, {action: "display", messages: [value]})
  end

  def login_action(commands)
    name = commands.first

    if(@current_account.present?)
      display "Already logged in."
      return
    end

    if(name.blank?)
      display "Login requires a login name"
      return
    end
    
    result = Account.where(name: name)
    if(result.blank?)
      display "Account not found"
      return
    end

    # LOGIN
    @current_account = result.first
    stream_from @current_account.observer.channel_id
    display "Logged in as #{@current_account.name}"
    update_status
    return
  end

  def logout_action(commands)
    if(@current_account.blank?)
      display "Not logged in"
    else # LOGOUT
      stop_stream_from @current_account.observer.channel_id
      @current_account = nil
      display "Logged out"
      update_status
    end
  end

  def register_action(commands)
    account = Account.create(name: commands.first)
    if(account.errors.present?)
      display "No."
    else
      display "New account created: #{account.name}"
    end
  end

  def status_action(commands)
    if(@current_account.blank?)
      display "Not logged in."
    else
      display "Logged in as #{@current_account.name}. Commanders are #{@current_account.commanders}. Observer is #{@current_account.observer}. Characters are #{@current_account.characters}"
    end
  end

  def update_status
    if(@current_account.present?)
      character_name = @current_account.characters.first.try(:name) || "None found"
      ActionCable.server.broadcast(connection_channel,{
        action: "status-update",
        account_name: @current_account.name,
        character_name: character_name
      })
    else
      ActionCable.server.broadcast(connection_channel, {action: "status-update", account_name: "Not logged in.", character_name: "No character selected."})
    end
  end
end
