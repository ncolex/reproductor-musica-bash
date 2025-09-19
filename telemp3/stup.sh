#!/bin/bash

# Configuración
PROYECTO_NAME="tele-music33"
API_KEY="AIzaSyDbF9NKDUl3EiICymGU_u1iY3mIwPNS0ls"  # ¡Verifica que sea válida para Gemini!
GITHUB_REPO="git@github.com:ncolex/TeleMUSIC33.git"
NETLIFY_SITE_NAME="tele-music33"  # Subdominio: tele-music33.netlify.app

echo "🚀 Iniciando setup para $PROYECTO_NAME..."

# 1. Crear proyecto con Vite
npm create vite@latest $PROYECTO_NAME -- --template react
cd $PROYECTO_NAME
npm install

# 2. Instalar dependencias
npm install @google/generative-ai

# 3. Configurar .env
cat > .env << EOF
VITE_API_KEY=$API_KEY
EOF

# 4. Crear src/App.jsx con código corregido y estilos Apple-like
cat > src/App.jsx << 'EOF'
import React, { useState, useEffect, useRef } from 'react';
import { GoogleGenerativeAI } from '@google/generative-ai';
import './App.css';

const genAI = new GoogleGenerativeAI(import.meta.env.VITE_API_KEY);

const App = () => {
  const [prompt, setPrompt] = useState('');
  const [messages, setMessages] = useState([
    { role: 'user', text: 'Hola, tengo 2 perros en mi casa.' },
    { role: 'assistant', text: '¡Encantado de conocerte! ¿Qué quieres saber?' }
  ]);
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!prompt.trim()) return;

    const newMessages = [...messages, { role: 'user', text: prompt }];
    setMessages(newMessages);
    setPrompt('');
    setIsLoading(true);

    try {
      const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
      const chat = model.startChat({ 
        history: newMessages.map(m => ({ role: m.role, parts: [{ text: m.text }] })),
        generationConfig: { maxOutputTokens: 100 }
      });
      const result = await chat.sendMessage(prompt);
      const responseText = result.response.text();
      setMessages([...newMessages, { role: 'assistant', text: responseText }]);
    } catch (error) {
      console.error(error);
      setMessages([...newMessages, { role: 'assistant', text: 'Lo siento, ocurrió un error. Intenta de nuevo.' }]);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="app">
      <header className="header">
        <h1>TeleMUSIC AI</h1>
        <p>Chatea con Gemini</p>
      </header>
      <div className="chat-container">
        <div className="messages">
          {messages.map((msg, idx) => (
            <div key={idx} className={`message ${msg.role}`}>
              <div className="bubble">{msg.text}</div>
            </div>
          ))}
          {isLoading && <div className="message assistant"><div className="bubble loading">Pensando...</div></div>}
          <div ref={messagesEndRef} />
        </div>
        <form onSubmit={handleSubmit} className="input-form">
          <input
            type="text"
            value={prompt}
            onChange={(e) => setPrompt(e.target.value)}
            placeholder="Escribe tu mensaje..."
            className="input"
            disabled={isLoading}
          />
          <button type="submit" disabled={isLoading} className="send-btn">
            {isLoading ? '⏳' : '→'}
          </button>
        </form>
      </div>
    </div>
  );
};

export default App;
EOF

# 5. Crear src/main.jsx
cat > src/main.jsx << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.jsx';
import './App.css';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
EOF

# 6. Estilos Apple-like en src/App.css
cat > src/App.css << 'EOF'
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background-color: #f2f2f7;
  color: #000;
  height: 100vh;
  overflow: hidden;
}

.app {
  display: flex;
  flex-direction: column;
  height: 100vh;
}

.header {
  background: linear-gradient(135deg, #007aff, #5856d6);
  color: white;
  padding: 1rem;
  text-align: center;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.header h1 {
  font-size: 1.5rem;
  font-weight: 600;
}

.header p {
  font-size: 0.9rem;
  opacity: 0.9;
}

.chat-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 1rem;
  overflow: hidden;
}

.messages {
  flex: 1;
  overflow-y: auto;
  padding-bottom: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.message {
  display: flex;
  max-width: 80%;
}

.message.user {
  align-self: flex-end;
}

.message.assistant {
  align-self: flex-start;
}

.bubble {
  padding: 0.75rem 1rem;
  border-radius: 18px;
  background: white;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  max-width: 100%;
  word-wrap: break-word;
  animation: fadeIn 0.3s ease;
}

.message.user .bubble {
  background: #007aff;
  color: white;
  border-bottom-right-radius: 4px;
}

.loading {
  background: #e5e5ea;
  color: #86868a;
}

.input-form {
  display: flex;
  gap: 0.5rem;
  padding: 1rem 0;
  background: white;
  border-top: 1px solid #d1d1d6;
}

.input {
  flex: 1;
  padding: 0.75rem 1rem;
  border: 1px solid #d1d1d6;
  border-radius: 18px;
  font-size: 1rem;
  outline: none;
}

.input:focus {
  border-color: #007aff;
}

.send-btn {
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 50%;
  background: #007aff;
  color: white;
  font-size: 1.2rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: opacity 0.2s;
}

.send-btn:hover:not(:disabled) {
  opacity: 0.8;
}

.send-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.messages::-webkit-scrollbar {
  width: 4px;
}

.messages::-webkit-scrollbar-track {
  background: transparent;
}

.messages::-webkit-scrollbar-thumb {
  background: #c7c7cc;
  border-radius: 2px;
}
EOF

# 7. Actualizar public/index.html
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>TeleMUSIC AI</title>
</head>
<body>
  <div id="root"></div>
</body>
</html>
EOF

# 8. Configurar .gitignore
cat > .gitignore << EOF
node_modules
dist
.env
.DS_Store
EOF

# 9. Configurar vite.config.js
cat > vite.config.js << 'EOF'
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
});
EOF

# 10. Inicializar Git y push a GitHub (usando SSH)
git init
git add .
git commit -m "Initial commit: Chat AI con Gemini - Estilo Apple"
git branch -M main
git remote add origin $GITHUB_REPO
git push -u origin main

echo "✅ Proyecto subido a GitHub: https://github.com/ncolex/TeleMUSIC33"

# 11. Build para despliegue
npm run build

# 12. Desplegar en Netlify
echo "📦 Instalando netlify-cli si no está instalado..."
npm install -g netlify-cli
echo "🔗 Conectando con Netlify... Sigue las instrucciones en la terminal."
netlify init --manual
netlify env:set VITE_API_KEY $API_KEY
netlify deploy --prod --dir=dist

echo "🚀 Desplegado en: https://$NETLIFY_SITE_NAME.netlify.app"
echo "¡Listo! Visita la URL para probar el chat."
