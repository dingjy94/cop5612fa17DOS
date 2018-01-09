import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

let connect_channnel = socket.channel("twitter:connect")
let messagesContainer = document.querySelector("#messages")
let loginButton = document.querySelector("#login-button")
let login_userInput = document.querySelector("#login-user-input")
let login_pwInput = document.querySelector("#login-password")

loginButton.addEventListener("click", event => {
    alert(userInput.value)
    channel.push("signin", {user: login_userInput.value, password: login_pwInput.value}).receive(
    "ok", (reply) => {
    let messageItem = document.createElement("li");
messageItem.innerText = ` ${reply.body}`
messagesContainer.appendChild(messageItem)
})
userInput.value = ""
pwInput.value = ""
emailInput.value = ""

})

channel.join()
    .receive("ok", resp => { console.log("Joined successfully log in", resp) })
.receive("error", resp => { console.log("Unable to join", resp) })

export var Login = { run: function() {
        // put initializer stuff here
        // for example:
        // $(document).on('click', '.remove-post', my_remove_post_function)
        let socket = new Socket("/socket", {params: {token: window.userToken}})
        socket.connect()
    }}

