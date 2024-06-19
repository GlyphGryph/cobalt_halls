import * as ActionCable from '@rails/actioncable'

const game = (window.CobaltHall || (window.CobaltHall = {}));
game.cable = ActionCable.createConsumer();
game.channel = game.cable.subscriptions.create({ channel: "GameChannel"}, {
  connected() {
    console.log("Connected to the channel:", this);
  },
  disconnected() {
    console.log("Disconnected");
  },
  received(data) {
    console.log(data);
    if("display" == data.action){
      const main_screen = document.getElementById('main-screen');
      for(const message of data.messages){
        let para = document.createElement("p");
        para.appendChild(document.createTextNode(message));
        main_screen.appendChild(para);
        main_screen.scrollIntoView(false);
      }
    }else if("status-update" == data.action){
      let account_element = document.getElementById('account-status-text');
      let character_element = document.getElementById('character-status-text');
      account_element.innerHTML = data.account_name;
      character_element.innerHTML = data.character_name;
    }else{
      console.log("Received some data:", data);
    }
  }
});

const command_box = document.getElementById("command-box");
command_box.addEventListener( "submit", function( e ){
  e.preventDefault();
  let command = command_box.querySelector('input').value;
  command_box.querySelector('input').value = "";
  game.channel.send({body: command});
});
