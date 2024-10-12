from fastapi import FastAPI

# from fastapi import FastAPI, WebSocket
# from fastapi.responses import HTMLResponse
from .ferdy import router

app = FastAPI()
app.include_router(router, prefix="/api")


# html = """
# <!DOCTYPE html>
# <html>
#     <head>
#         <title>WebSocket Multimedia Example</title>
#     </head>
#     <body>
#         <h1>WebSocket Multimedia Example</h1>

#         <h2>Send Text</h2>
#         <input type="text" id="textInput" />
#         <button onclick="sendText()">Send Text</button><br><br>

#         <h2>Send Image</h2>
#         <input type="file" id="imageInput" accept="image/*" /><br>
#         <button onclick="sendImage()">Send Image</button><br>
#         <img id="receivedImage" style="max-width: 300px;" /><br><br>

#         <h2>Send Audio</h2>
#         <input type="file" id="audioInput" accept="audio/*" /><br>
#         <button onclick="sendAudio()">Send Audio</button><br>
#         <audio id="receivedAudio" controls></audio><br><br>

#         <script>
#             var ws = new WebSocket("ws://localhost:8000/ws");
#             ws.binaryType = "arraybuffer";

#             ws.onmessage = function(event) {
#                 // First byte determines the type of message
#                 var dataView = new DataView(event.data);
#                 var type = dataView.getUint8(0); // Get the first byte (type identifier)

#                 if (type === 1) {
#                     // Handle text message
#                     var textDecoder = new TextDecoder();
#                     var text = textDecoder.decode(event.data.slice(1));
#                     alert("Received Text: " + text);
#                 } else if (type === 2) {
#                     // Handle image
#                     var blob = new Blob([event.data.slice(1)], { type: "image/jpeg" });  // assuming jpeg image
#                     var imgUrl = URL.createObjectURL(blob);
#                     document.getElementById("receivedImage").src = imgUrl;
#                 } else if (type === 3) {
#                     // Handle audio
#                     var blob = new Blob([event.data.slice(1)], { type: "audio/mpeg" });  // assuming mp3
#                     var audioUrl = URL.createObjectURL(blob);
#                     document.getElementById("receivedAudio").src = audioUrl;
#                 }
#             };

#             function sendText() {
#                 var text = document.getElementById("textInput").value;
#                 var textEncoder = new TextEncoder();
#                 var encodedText = textEncoder.encode(text);
#                 var payload = new Uint8Array(1 + encodedText.length);
#                 payload[0] = 1;  // 1 for text
#                 payload.set(encodedText, 1);
#                 ws.send(payload);
#             }

#             function sendImage() {
#                 var fileInput = document.getElementById("imageInput");
#                 var file = fileInput.files[0];
#                 var reader = new FileReader();

#                 reader.onload = function(event) {
#                     var arrayBuffer = event.target.result;
#                     var payload = new Uint8Array(1 + arrayBuffer.byteLength);
#                     payload[0] = 2;  // 2 for image
#                     payload.set(new Uint8Array(arrayBuffer), 1);
#                     ws.send(payload);
#                 };

#                 if (file) {
#                     reader.readAsArrayBuffer(file);
#                 }
#             }

#             function sendAudio() {
#                 var fileInput = document.getElementById("audioInput");
#                 var file = fileInput.files[0];
#                 var reader = new FileReader();

#                 reader.onload = function(event) {
#                     var arrayBuffer = event.target.result;
#                     var payload = new Uint8Array(1 + arrayBuffer.byteLength);
#                     payload[0] = 3;  // 3 for audio
#                     payload.set(new Uint8Array(arrayBuffer), 1);
#                     ws.send(payload);
#                 };

#                 if (file) {
#                     reader.readAsArrayBuffer(file);
#                 }
#             }
#         </script>
#     </body>
# </html>
# """


# @app.get("/")
# async def get():
#     return HTMLResponse(html)


# @app.websocket("/ws")
# async def websocket_endpoint(websocket: WebSocket):
#     await websocket.accept()
#     while True:
#         # Receive the data as bytes
#         data = await websocket.receive_bytes()

#         # First byte determines the type of message
#         type_of_message = data[0]

#         if type_of_message == 1:
#             # Handle text message
#             text = data[1:].decode("utf-8")
#             print(f"Received text: {text}")

#             await websocket.send_bytes(bytes([1]) + data[1:])  # Echo back the text

#         elif type_of_message == 2:
#             # Handle image
#             print(f"Received image of size {len(data[1:])} bytes")
#             await websocket.send_bytes(bytes([2]) + data[1:])

#         elif type_of_message == 3:
#             # Handle audio
#             print(f"Received audio of size {len(data[1:])} bytes")
#             await websocket.send_bytes(bytes([3]) + data[1:])


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
