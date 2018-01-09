// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("twitter:signup", {})
let connect_channel = socket.channel("twitter:connect")
let userInput         = document.querySelector("#user-input")
let pwInput = document.querySelector("#password-input")
let emailInput = document.querySelector("#email-input")
let messagesContainer = document.querySelector("#messages")
let gotweetContainer = document.querySelector("#gotweet")
let signupButton = document.querySelector("#sign-up-button")
let loginButton = document.querySelector("#login-button")
let login_userInput = document.querySelector("#login-user-input")
let login_pwInput = document.querySelector("#login-password-input")
let tweet = document.querySelector("#tweet")
let send = document.querySelector("#send")
let argument = document.querySelector("#argument")
let method = document.querySelector("#method")
let query = document.querySelector("#query")
let result = document.querySelector("#result")
let user = document.querySelector("#user")
let subscribe = document.querySelector("#subscribe")

let email = document.querySelector("#email")

subscribe.addEventListener("click", event => {
    //alert(userInput.value)
    connect_channel.push("subscribe", {email: user.value, self: email.value}).receive(
    "ok", (reply) => {
    alert(` ${reply.body}`)



})


})
query.addEventListener("click", event => {
    //alert(userInput.value)
    connect_channel.push("query", {argument: argument.value, method: method.value}).receive(
    "ok", (reply) => {
    let resultItem = document.createElement("div");


var x = reply.body.length
console.log(x)
var i
for (i=0; i<x;i++ ) {
    console.log(` ${reply.body[i]}`)
    resultItem.innerHTML += (`<div >`+ `${reply.body[i]}`+`</div>`)
    result.appendChild(resultItem)
}


})


})

send.addEventListener("click", event => {
    //alert(userInput.value)
    connect_channel.push("tweet", {email: "client1@gmail.com", tweet: tweet.value}).receive(
    "ok", (reply) => {
     alert(` ${reply.body}`)



})


})

loginButton.addEventListener("click", event => {
    //alert(userInput.value)
    connect_channel.push("signin", {user: login_userInput.value, password: login_pwInput.value}).receive(
    "ok", (reply) => {
    let messageItem = document.createElement("div");
    let gotweetItem = document.createElement("div");
    gotweetItem.innerHTML = (`<div><button onclick="window.location.href='http://localhost:4000/tweet'" >Tweet New Message</button><button onclick="window.location.href='http://localhost:4000/query'" >Query Hashtag or mention</button><button onclick="window.location.href='http://localhost:4000/subscribe'" >Subscribe User</button></div>`)
    gotweetContainer.appendChild(gotweetItem)

    var x = reply.body.length
console.log(x)
var i
for (i=0; i<x;i++ ) {
        console.log(` ${reply.body[i]}`)
    messageItem.innerHTML += (`<div >`+ `${reply.body[i]}`+`</div>` + `<div> <button onclick="alert('Retweet this tweet?')" id="retweet" >retweet</button>`)
    messagesContainer.appendChild(messageItem)
}
})


})

signupButton.addEventListener("click", event => {
  //alert(userInput.value)
    channel.push("signup", {user: userInput.value, password: pwInput.value, email: emailInput.value}).receive(
    "ok", (reply) => {
      let messageItem = document.createElement("li");
messageItem.innerText = ` ${reply.body}`
messagesContainer.appendChild(messageItem)
})

    window.location.href='http://localhost:4000/login'

})

channel.on("signup", payload => {
    let messageItem = document.createElement("li");
messageItem.innerText = `${payload.body}`
messagesContainer.appendChild(messageItem)
})

channel.on("new_msg", payload => {
    let messageItem = document.createElement("li");
messageItem.innerText = `[${Date()}] ${payload.body}`
messagesContainer.appendChild(messageItem)
})

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

connect_channel.join()
    .receive("ok", resp => { console.log("connected successfully", resp) })
.receive("error", resp => { console.log("Unable to join", resp) })

export default socket
