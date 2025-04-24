# ✨ CF-Assistant ✨

<div align="center">

  ![CF-Assistant Logo](assets/cf_logo.png)

  <h3>Your AI-Powered Voice Assistant</h3>

  <p>CF-Assistant is a Flutter-based voice assistant application that integrates with Flowise AI to provide a conversational interface. The app allows users to interact with AI through both text and voice inputs, making it versatile for various use cases.</p>

  [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

</div>

<br>

## 🌟 Features

<div align="center">
  <table>
    <tr>
      <td align="center">🎤</td>
      <td><b>Voice Recognition</b> - Speak to the assistant and get voice responses</td>
    </tr>
    <tr>
      <td align="center">⌨️</td>
      <td><b>Text Input</b> - Type your queries when voice isn't preferred</td>
    </tr>
    <tr>
      <td align="center">🔊</td>
      <td><b>Live Voice Chat</b> - Real-time voice conversation mode</td>
    </tr>
    <tr>
      <td align="center">🌓</td>
      <td><b>Theme Customization</b> - Switch between light, dark, and system themes</td>
    </tr>
    <tr>
      <td align="center">📜</td>
      <td><b>Chat History</b> - View and manage your conversation history</td>
    </tr>
    <tr>
      <td align="center">🔄</td>
      <td><b>Multiple Chat Flows</b> - Configure different AI flows for different purposes</td>
    </tr>
    <tr>
      <td align="center">📎</td>
      <td><b>File Attachments</b> - Share images and files with the assistant</td>
    </tr>
    <tr>
      <td align="center">🔧</td>
      <td><b>Voice Settings</b> - Customize voice parameters like speech rate and pitch</td>
    </tr>
  </table>
</div>

<br>

## 🚀 Technologies Used

<div align="center">
  <table>
    <tr>
      <td align="center">📱</td>
      <td><b>Flutter</b> - Cross-platform UI framework</td>
    </tr>
    <tr>
      <td align="center">💻</td>
      <td><b>Dart</b> - Programming language</td>
    </tr>
    <tr>
      <td align="center">🧠</td>
      <td><b>Provider</b> - State management</td>
    </tr>
    <tr>
      <td align="center">🤖</td>
      <td><b>Flowise AI</b> - Backend AI service</td>
    </tr>
    <tr>
      <td align="center">🗣️</td>
      <td><b>Speech-to-Text & Flutter TTS</b> - Voice capabilities</td>
    </tr>
    <tr>
      <td align="center">💾</td>
      <td><b>Shared Preferences</b> - Local storage</td>
    </tr>
    <tr>
      <td align="center">🌐</td>
      <td><b>HTTP</b> - API communication</td>
    </tr>
  </table>
</div>

<br>

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

<div align="center">
  <table>
    <tr>
      <td align="center">📦</td>
      <td><a href="https://flutter.dev/docs/get-started/install"><b>Flutter SDK</b></a> (2.19.0 or higher)</td>
    </tr>
    <tr>
      <td align="center">🎯</td>
      <td><a href="https://dart.dev/get-dart"><b>Dart SDK</b></a> (compatible with your Flutter version)</td>
    </tr>
    <tr>
      <td align="center">🧰</td>
      <td><b>An IDE</b> (VS Code, Android Studio, or IntelliJ)</td>
    </tr>
    <tr>
      <td align="center">☁️</td>
      <td><b>A Flowise AI instance</b> (for backend AI processing)</td>
    </tr>
  </table>
</div>

<br>

## 🔧 Installation and Setup

<div align="left">

### 1️⃣ Clone the repository

```bash
git clone https://github.com/yourusername/CF-Assistant.git
cd CF-Assistant
```

### 2️⃣ Install dependencies

```bash
flutter pub get
```

### 3️⃣ Create environment file

Create a `.env` file in the root directory with the following variables:

```
# Optional default Flowise configuration
DEFAULT_FLOWISE_URL=https://your-flowise-instance.com
DEFAULT_FLOWISE_API_KEY=your-api-key
DEFAULT_FLOW_ID=your-default-flow-id
```

### 4️⃣ Run the app

```bash
flutter run
```

</div>

<br>

## ⚙️ Configuration

<div align="left">

### 🤖 Flowise AI Setup

1. Set up a [Flowise AI](https://github.com/FlowiseAI/Flowise) instance
2. Create a chat flow in Flowise
3. Get your Flow ID from the Flowise dashboard
4. Configure the app to use your Flowise instance:
   - Go to Settings > Chat Flows
   - Add a new chat flow with your Flowise URL, API key, and Flow ID

### 🔊 Voice Settings

You can customize the voice assistant's speech parameters:
- 🔉 Speech rate
- 🎵 Pitch
- 🗣️ Voice selection
- 🌐 Language

</div>

<br>

## 📱 Usage

<div align="left">

### 💬 Text Chat
1. Type your message in the input field
2. Press send or hit Enter
3. View the AI's response in the chat

### 🎤 Voice Input
1. Tap the microphone button
2. Speak your query
3. Release to send and receive a text response

### 🔊 Live Voice Chat
1. Tap the live voice chat button
2. Have a continuous conversation with the assistant
3. The assistant will respond with voice

### ⚙️ Managing Chat Flows
1. Open the sidebar
2. Go to Chat Flows
3. Add, edit, or delete chat flows
4. Select the active chat flow for your current session

</div>

<br>

## 📂 Project Structure

<div align="center">
  <table>
    <tr>
      <td align="center">📁</td>
      <td><b>lib/</b> - Main source code directory</td>
    </tr>
    <tr>
      <td align="center">┣━ 📁</td>
      <td><b>models/</b> - Data models for the application</td>
    </tr>
    <tr>
      <td align="center">┃  ┣━ 📄</td>
      <td><b>chat_flow.dart</b> - Model for Flowise chat flow configuration</td>
    </tr>
    <tr>
      <td align="center">┃  ┗━ 📄</td>
      <td><b>chat_message.dart</b> - Model for chat messages</td>
    </tr>
    <tr>
      <td align="center">┣━ 📁</td>
      <td><b>providers/</b> - State management using Provider pattern</td>
    </tr>
    <tr>
      <td align="center">┃  ┣━ 📄</td>
      <td><b>auth_provider.dart</b> - Authentication state management</td>
    </tr>
    <tr>
      <td align="center">┃  ┣━ 📄</td>
      <td><b>chat_flow_provider.dart</b> - Chat flow configuration management</td>
    </tr>
    <tr>
      <td align="center">┃  ┣━ 📄</td>
      <td><b>chat_provider.dart</b> - Chat messages and history management</td>
    </tr>
    <tr>
      <td align="center">┃  ┗━ 📄</td>
      <td><b>theme_provider.dart</b> - Theme settings management</td>
    </tr>
    <tr>
      <td align="center">┣━ 📁</td>
      <td><b>screens/</b> - App screens/pages</td>
    </tr>
    <tr>
      <td align="center">┃  ┣━ 📄</td>
      <td><b>chat_screen.dart</b> - Main chat interface</td>
    </tr>
    <tr>
      <td align="center">┃  ┣━ 📄</td>
      <td><b>live_voice_screen.dart</b> - Voice conversation interface</td>
    </tr>
    <tr>
      <td align="center">┃  ┣━ 📄</td>
      <td><b>settings_screen.dart</b> - App settings</td>
    </tr>
    <tr>
      <td align="center">┃  ┣━ 📄</td>
      <td><b>history_screen.dart</b> - Chat history view</td>
    </tr>
    <tr>
      <td align="center">┃  ┣━ 📄</td>
      <td><b>help_center_screen.dart</b> - Help and documentation</td>
    </tr>
    <tr>
      <td align="center">┃  ┣━ 📄</td>
      <td><b>sign_in_screen.dart</b> - User login</td>
    </tr>
    <tr>
      <td align="center">┃  ┗━ 📄</td>
      <td><b>signup_screen.dart</b> - User registration</td>
    </tr>
    <tr>
      <td align="center">┣━ 📁</td>
      <td><b>widgets/</b> - Reusable UI components</td>
    </tr>
    <tr>
      <td align="center">┃  ┣━ 📄</td>
      <td><b>chat_message_widget.dart</b> - Chat message bubble</td>
    </tr>
    <tr>
      <td align="center">┃  ┣━ 📄</td>
      <td><b>voice_input_button.dart</b> - Voice input control</td>
    </tr>
    <tr>
      <td align="center">┃  ┣━ 📄</td>
      <td><b>Live_voice_chat.dart</b> - Live voice chat component</td>
    </tr>
    <tr>
      <td align="center">┃  ┣━ 📄</td>
      <td><b>text_input_field.dart</b> - Text input component</td>
    </tr>
    <tr>
      <td align="center">┃  ┣━ 📄</td>
      <td><b>sidebar.dart</b> - App navigation sidebar</td>
    </tr>
    <tr>
      <td align="center">┃  ┣━ 📄</td>
      <td><b>chat_flow_dialog.dart</b> - Dialog for configuring chat flows</td>
    </tr>
    <tr>
      <td align="center">┃  ┣━ 📄</td>
      <td><b>chat_flow_selector.dart</b> - UI for selecting active chat flow</td>
    </tr>
    <tr>
      <td align="center">┃  ┣━ 📄</td>
      <td><b>attachment_button.dart</b> - Button for adding file attachments</td>
    </tr>
    <tr>
      <td align="center">┃  ┣━ 📄</td>
      <td><b>voice-settings.dart</b> - Voice configuration options</td>
    </tr>
    <tr>
      <td align="center">┃  ┗━ 📄</td>
      <td><b>footer_widget.dart</b> - App footer component</td>
    </tr>
    <tr>
      <td align="center">┗━ 📄</td>
      <td><b>main.dart</b> - Application entry point</td>
    </tr>
    <tr>
      <td align="center">📁</td>
      <td><b>assets/</b> - Images, animations, and other static files</td>
    </tr>
    <tr>
      <td align="center">📄</td>
      <td><b>.env</b> - Environment variables configuration</td>
    </tr>
  </table>
</div>

<br>

## 🤝 Contributing

<div align="center">

  ### Contributions are welcome! Please feel free to submit a Pull Request.

</div>

<div align="left">

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

</div>

<br>

## 📄 License

<div align="center">

  ### This project is licensed under the MIT License - see the LICENSE file for details.

</div>

<br>

<div align="center">

  ### Made with ❤️ by the CF-Assistant Team

  <p>© 2024 CF-Assistant</p>

</div>
#   C F - A s s i s t a n t  
 