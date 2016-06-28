/* jshint esversion: 6 */

import {Socket, LongPoller} from "phoenix";

class App {

  static init(){
    let socket = new Socket("/socket", {
      logger: ((kind, msg, data) => { console.log(`${kind}: ${msg}`, data) })
    })

    socket.connect({user_id: "123"})
    var $status    = $("#status")
    var $messages  = $("#messages")
    var $room_id  = $("#messages").data("room-id") || "lobby"
    var $input     = $("#message-input")
    var $username  = $("#username")
    var $image_input = $("#image-input")
    var $image_api_url = $image_input.data("image-api-url")
    var is_image = function(message) {
      return message.includes($image_api_url) || /(https?)(:\/\/[-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%#]+)\.(jpg|gif|png)/y.test(message)
    }

    socket.onOpen( ev => console.log("OPEN", ev) )
    socket.onError( ev => console.log("ERROR", ev) )
    socket.onClose( e => console.log("CLOSE", e))

    var chan = socket.channel("rooms:" + $room_id, {})
    chan.join().receive("ignore", () => console.log("auth error"))
               .receive("ok", () => console.log("join ok"))
               //.after(10000, () => console.log("Connection interruption"))
    chan.onError(e => console.log("something went wrong", e))
    chan.onClose(e => console.log("channel closed", e))

    $input.off("keypress").on("keypress", e => {
      var input_value = $input.val()
      if (e.keyCode == 13 && input_value != '') {
        chan.push("new:msg", {user: $username.val(), body: $input.val()})
        $input.val("")
      }
    })

    $image_input.on("change", e => {
      var input_file = e.target.files[0];
      if (input_file.type.match(/^image\/(jpeg|jpg|png)$/)) {
        var reader = new FileReader();
        reader.onload = function(e) {
          var uint8ArrayToBinaryString = function(data) {
            var result = "";
            data.forEach(function(c) {
              result += String.fromCharCode(c);
            });
            return result;
          };
          var result = uint8ArrayToBinaryString(new Uint8Array(e.target.result));
          chan.push("new:resource", {
            user: $username.val(),
            content_type: input_file.type,
            filename: input_file.name,
            raw_data: result
          });
        };
        reader.readAsArrayBuffer(input_file);

      } else {
        alert('jpegまたはpngを選んでください！');
      }
    });

    chan.on("new:msg", msg => {
      $messages.append(this.messageTemplate(msg))
      scrollTo(0, document.body.scrollHeight)
    })
    // chan.on("system:ping", msg => {
    //   console.log("recieve ping")
    // })
    chan.on("new:img", msg => {
      $messages.append(this.imageTemplate(msg))
      scrollTo(0, document.body.scrollHeight)
    })

    chan.on("user:entered", msg => {
      var username = this.sanitize(msg.user || "anonymous")
      $messages.append(`<br/><i>[${username} entered]</i>`)
    })
  }

  static sanitize(html){ return $("<div/>").text(html).html() }

  static messageTemplate(msg){
    let username = this.sanitize(msg.user || "anonymous")
    let body     = this.sanitize(msg.body)

    return(`<p><a href='#'>[${username}]</a>&nbsp; ${body}</p>`)
  }

  static imageTemplate(msg){
    let username = this.sanitize(msg.user || "anonymous")
    let body     = this.sanitize(msg.body)

    return(`<p><a href='#'>[${username}]</a><img src='${body}' style='max-width: 400px'/></p>`)
  }

}

$( () => App.init() )

export default App
