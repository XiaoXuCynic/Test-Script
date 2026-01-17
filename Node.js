<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Roblox Lua/Luau 脚本混淆器</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        body {
            background-color: #0f172a;
            color: #e2e8f0;
            line-height: 1.6;
            padding: 20px;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #334155;
        }
        
        h1 {
            color: #60a5fa;
            font-size: 2.5rem;
            margin-bottom: 10px;
        }
        
        .subtitle {
            color: #94a3b8;
            font-size: 1.1rem;
        }
        
        .main-content {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-bottom: 40px;
        }
        
        @media (max-width: 900px) {
            .main-content {
                grid-template-columns: 1fr;
            }
        }
        
        .panel {
            background-color: #1e293b;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.3);
            border: 1px solid #334155;
        }
        
        .panel h2 {
            color: #38bdf8;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #334155;
            font-size: 1.5rem;
        }
        
        .file-upload-area {
            border: 2px dashed #4f46e5;
            border-radius: 8px;
            padding: 40px 20px;
            text-align: center;
            margin-bottom: 25px;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .file-upload-area:hover {
            background-color: #2d3748;
            border-color: #7c3aed;
        }
        
        .upload-icon {
            font-size: 3rem;
            color: #60a5fa;
            margin-bottom: 15px;
        }
        
        .file-input {
            display: none;
        }
        
        textarea {
            width: 100%;
            min-height: 300px;
            background-color: #0f172a;
            color: #cbd5e1;
            border: 1px solid #475569;
            border-radius: 6px;
            padding: 15px;
            font-family: 'Courier New', monospace;
            font-size: 14px;
            resize: vertical;
            margin-bottom: 20px;
        }
        
        textarea:focus {
            outline: none;
            border-color: #60a5fa;
        }
        
        .button-group {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
        }
        
        button {
            padding: 12px 24px;
            background-color: #4f46e5;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
            font-size: 1rem;
            transition: all 0.2s ease;
            flex: 1;
            min-width: 140px;
        }
        
        button:hover {
            background-color: #7c3aed;
            transform: translateY(-2px);
        }
        
        button:active {
            transform: translateY(0);
        }
        
        .obfuscate-btn {
            background-color: #059669;
        }
        
        .obfuscate-btn:hover {
            background-color: #10b981;
        }
        
        .clear-btn {
            background-color: #dc2626;
        }
        
        .clear-btn:hover {
            background-color: #ef4444;
        }
        
        .admin-btn {
            background-color: #6366f1;
        }
        
        .admin-btn:hover {
            background-color: #818cf8;
        }
        
        .result-info {
            background-color: #0f766e;
            color: white;
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .admin-panel {
            display: none;
            margin-top: 40px;
        }
        
        .admin-panel.active {
            display: block;
        }
        
        .code-list {
            max-height: 400px;
            overflow-y: auto;
            margin-top: 20px;
        }
        
        .code-item {
            background-color: #334155;
            border-radius: 6px;
            padding: 15px;
            margin-bottom: 15px;
            border-left: 4px solid #60a5fa;
        }
        
        .code-item-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            font-size: 0.9rem;
            color: #94a3b8;
        }
        
        .code-preview {
            background-color: #0f172a;
            padding: 10px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            font-size: 0.9rem;
            overflow-x: auto;
            white-space: pre-wrap;
            max-height: 150px;
            overflow-y: auto;
        }
        
        .stats {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #334155;
            flex-wrap: wrap;
            gap: 15px;
        }
        
        .stat-item {
            text-align: center;
            flex: 1;
            min-width: 150px;
        }
        
        .stat-value {
            font-size: 2rem;
            color: #60a5fa;
            font-weight: 700;
        }
        
        .stat-label {
            color: #94a3b8;
            font-size: 0.9rem;
        }
        
        footer {
            text-align: center;
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #334155;
            color: #64748b;
            font-size: 0.9rem;
        }
        
        .notification {
            position: fixed;
            bottom: 20px;
            right: 20px;
            background-color: #059669;
            color: white;
            padding: 15px 25px;
            border-radius: 6px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
            display: none;
            z-index: 1000;
        }
        
        .notification.show {
            display: block;
            animation: slideIn 0.3s ease;
        }
        
        @keyframes slideIn {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        
        .loading {
            display: none;
            text-align: center;
            margin: 20px 0;
        }
        
        .loading.active {
            display: block;
        }
        
        .spinner {
            border: 4px solid rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            border-top: 4px solid #60a5fa;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto 10px;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>Roblox Lua/Luau 脚本混淆器</h1>
            <p class="subtitle">上传您的Lua/Luau代码，进行混淆加密保护，并查看后台存储的脚本</p>
        </header>
        
        <div class="main-content">
            <div class="panel">
                <h2>上传和编辑代码</h2>
                <div class="file-upload-area" id="uploadArea">
                    <div class="upload-icon">📁</div>
                    <p>点击此处上传Lua/Luau文件，或拖放文件到此处</p>
                    <p style="font-size: 0.9rem; color: #94a3b8; margin-top: 10px;">支持 .lua 和 .luau 文件格式</p>
                    <input type="file" id="fileInput" class="file-input" accept=".lua,.luau">
                </div>
                
                <textarea id="codeInput" placeholder="在此粘贴或编辑您的Lua/Luau代码...">-- 示例代码
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

function greetPlayer(name)
    print("欢迎, " .. name .. "!")
    return "问候已发送"
end

local result = greetPlayer(player.Name)
print(result)

for i = 1, 5 do
    print("迭代: " .. i)
end</textarea>
                
                <div class="button-group">
                    <button id="obfuscateBtn" class="obfuscate-btn">混淆代码</button>
                    <button id="clearBtn" class="clear-btn">清空代码</button>
                    <button id="adminBtn" class="admin-btn">查看后台</button>
                </div>
            </div>
            
            <div class="panel">
                <h2>混淆结果</h2>
                <div class="result-info">
                    <span id="resultTitle">等待混淆...</span>
                    <span id="charCount">0 字符</span>
                </div>
                
                <textarea id="codeOutput" placeholder="混淆后的代码将显示在这里..." readonly></textarea>
                
                <div class="button-group">
                    <button id="copyBtn">复制结果</button>
                    <button id="downloadBtn">下载代码</button>
                </div>
                
                <div class="loading" id="loadingIndicator">
                    <div class="spinner"></div>
                    <p>正在混淆代码...</p>
                </div>
            </div>
        </div>
        
        <div class="admin-panel" id="adminPanel">
            <div class="panel">
                <h2>后台 - 已上传的代码</h2>
                <p style="margin-bottom: 15px; color: #94a3b8;">这里存储了所有已上传的代码，包括原始代码和混淆后的版本。</p>
                
                <div class="button-group">
                    <button id="refreshAdminBtn">刷新列表</button>
                    <button id="clearAllBtn" class="clear-btn">清除所有记录</button>
                    <button id="closeAdminBtn">关闭后台</button>
                </div>
                
                <div class="code-list" id="codeList">
                    <!-- 代码记录将在这里动态生成 -->
                </div>
            </div>
        </div>
        
        <div class="stats">
            <div class="stat-item">
                <div class="stat-value" id="totalScripts">0</div>
                <div class="stat-label">总脚本数</div>
            </div>
            <div class="stat-item">
                <div class="stat-value" id="totalObfuscated">0</div>
                <div class="stat-label">已混淆脚本</div>
            </div>
            <div class="stat-item">
                <div class="stat-value" id="totalCharacters">0</div>
                <div class="stat-label">总字符数</div>
            </div>
            <div class="stat-item">
                <div class="stat-value" id="todayUploads">0</div>
                <div class="stat-label">今日上传</div>
            </div>
        </div>
        
        <footer>
            <p>Roblox Lua/Luau 脚本混淆器 | 仅供学习和演示用途 | 实际部署请考虑服务器端存储</p>
        </footer>
        
        <div class="notification" id="notification">
            <span id="notificationText">操作成功！</span>
        </div>
    </div>

    <script>
        // 数据库模拟 - 使用IndexedDB存储代码记录
        let db;
        const DB_NAME = 'LuaObfuscatorDB';
        const DB_VERSION = 1;
        const STORE_NAME = 'scripts';
        
        // 初始化数据库
        function initDB() {
            const request = indexedDB.open(DB_NAME, DB_VERSION);
            
            request.onerror = function(event) {
                console.error('数据库初始化失败:', event.target.error);
                // 如果IndexedDB不可用，使用localStorage作为备选
                console.log('将使用localStorage作为备选存储方案');
            };
            
            request.onsuccess = function(event) {
                db = event.target.result;
                console.log('数据库初始化成功');
                updateStats();
                loadAdminCodeList();
            };
            
            request.onupgradeneeded = function(event) {
                db = event.target.result;
                
                // 创建对象存储
                if (!db.objectStoreNames.contains(STORE_NAME)) {
                    const objectStore = db.createObjectStore(STORE_NAME, { keyPath: 'id', autoIncrement: true });
                    objectStore.createIndex('timestamp', 'timestamp', { unique: false });
                    objectStore.createIndex('obfuscated', 'obfuscated', { unique: false });
                }
            };
        }
        
        // 保存代码到数据库
        function saveCode(originalCode, obfuscatedCode) {
            if (!db) {
                // 使用localStorage作为备选
                const scripts = JSON.parse(localStorage.getItem('luaScripts') || '[]');
                const newScript = {
                    id: Date.now(),
                    timestamp: new Date().toISOString(),
                    originalCode: originalCode,
                    obfuscatedCode: obfuscatedCode,
                    obfuscated: true,
                    charCount: originalCode.length
                };
                scripts.push(newScript);
                localStorage.setItem('luaScripts', JSON.stringify(scripts));
                showNotification('代码已保存到本地存储');
                updateStats();
                loadAdminCodeList();
                return;
            }
            
            const transaction = db.transaction([STORE_NAME], 'readwrite');
            const objectStore = transaction.objectStore(STORE_NAME);
            
            const script = {
                timestamp: new Date().toISOString(),
                originalCode: originalCode,
                obfuscatedCode: obfuscatedCode,
                obfuscated: true,
                charCount: originalCode.length
            };
            
            const request = objectStore.add(script);
            
            request.onsuccess = function() {
                console.log('代码已保存到数据库');
                showNotification('代码已保存到后台');
                updateStats();
                loadAdminCodeList();
            };
            
            request.onerror = function(event) {
                console.error('保存代码失败:', event.target.error);
                showNotification('保存失败，请重试', 'error');
            };
        }
        
        // 获取所有代码记录
        function getAllScripts(callback) {
            if (!db) {
                // 从localStorage获取
                const scripts = JSON.parse(localStorage.getItem('luaScripts') || '[]');
                callback(scripts);
                return;
            }
            
            const transaction = db.transaction([STORE_NAME], 'readonly');
            const objectStore = transaction.objectStore(STORE_NAME);
            const request = objectStore.getAll();
            
            request.onsuccess = function(event) {
                callback(event.target.result);
            };
            
            request.onerror = function(event) {
                console.error('获取代码记录失败:', event.target.error);
                callback([]);
            };
        }
        
        // 清除所有记录
        function clearAllScripts() {
            if (!confirm('确定要清除所有代码记录吗？此操作不可撤销。')) {
                return;
            }
            
            if (!db) {
                localStorage.removeItem('luaScripts');
                showNotification('所有记录已清除');
                updateStats();
                loadAdminCodeList();
                return;
            }
            
            const transaction = db.transaction([STORE_NAME], 'readwrite');
            const objectStore = transaction.objectStore(STORE_NAME);
            const request = objectStore.clear();
            
            request.onsuccess = function() {
                showNotification('所有记录已清除');
                updateStats();
                loadAdminCodeList();
            };
            
            request.onerror = function(event) {
                console.error('清除记录失败:', event.target.error);
                showNotification('清除失败，请重试', 'error');
            };
        }
        
        // 更新统计信息
        function updateStats() {
            getAllScripts(function(scripts) {
                document.getElementById('totalScripts').textContent = scripts.length;
                
                const obfuscatedCount = scripts.filter(s => s.obfuscated).length;
                document.getElementById('totalObfuscated').textContent = obfuscatedCount;
                
                const totalChars = scripts.reduce((sum, script) => sum + (script.charCount || 0), 0);
                document.getElementById('totalCharacters').textContent = totalChars.toLocaleString();
                
                // 计算今日上传数
                const today = new Date().toISOString().split('T')[0];
                const todayUploads = scripts.filter(s => s.timestamp && s.timestamp.startsWith(today)).length;
                document.getElementById('todayUploads').textContent = todayUploads;
            });
        }
        
        // 加载后台代码列表
        function loadAdminCodeList() {
            getAllScripts(function(scripts) {
                const codeList = document.getElementById('codeList');
                codeList.innerHTML = '';
                
                if (scripts.length === 0) {
                    codeList.innerHTML = '<div class="code-item"><p style="text-align: center; color: #94a3b8;">暂无代码记录</p></div>';
                    return;
                }
                
                // 按时间倒序排列
                scripts.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
                
                scripts.forEach(script => {
                    const date = new Date(script.timestamp);
                    const dateStr = date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
                    
                    const codeItem = document.createElement('div');
                    codeItem.className = 'code-item';
                    
                    const previewCode = script.originalCode.length > 200 
                        ? script.originalCode.substring(0, 200) + '...' 
                        : script.originalCode;
                    
                    codeItem.innerHTML = `
                        <div class="code-item-header">
                            <span>ID: ${script.id || 'N/A'}</span>
                            <span>${dateStr}</span>
                            <span>${script.charCount || script.originalCode.length} 字符</span>
                        </div>
                        <div class="code-preview">${escapeHtml(previewCode)}</div>
                    `;
                    
                    codeList.appendChild(codeItem);
                });
            });
        }
        
        // Lua/Luau 混淆函数
        function obfuscateLuaCode(code) {
            if (!code || code.trim() === '') {
                return '';
            }
            
            // 基本混淆策略：
            // 1. 重命名局部变量和函数名
            // 2. 移除注释和额外空格
            // 3. 简化代码结构
            
            let obfuscated = code;
            
            // 移除单行和多行注释
            obfuscated = obfuscated.replace(/--\[\[[\s\S]*?\]\]/g, '');
            obfuscated = obfuscated.replace(/--[^\n]*/g, '');
            
            // 提取所有局部变量名
            const localVarRegex = /local\s+([a-zA-Z_][a-zA-Z0-9_]*)/g;
            const localVars = [];
            let match;
            
            while ((match = localVarRegex.exec(code)) !== null) {
                if (!localVars.includes(match[1])) {
                    localVars.push(match[1]);
                }
            }
            
            // 提取函数名
            const functionRegex = /function\s+([a-zA-Z_][a-zA-Z0-9_]*)/g;
            const functions = [];
            
            while ((match = functionRegex.exec(code)) !== null) {
                if (!functions.includes(match[1])) {
                    functions.push(match[1]);
                }
            }
            
            // 创建变量名映射
            const varMap = {};
            const usedNames = new Set();
            
            // 生成混淆后的变量名
            function generateObfName(base) {
                const prefix = ['_', 'a', 'b', 'c', 'x', 'y', 'z'];
                const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
                let name;
                
                // 先尝试使用短名
                for (let p of prefix) {
                    name = p + Math.floor(Math.random() * 10);
                    if (!usedNames.has(name)) {
                        usedNames.add(name);
                        return name;
                    }
                }
                
                // 如果短名都被使用，生成随机名
                do {
                    name = '';
                    for (let i = 0; i < 6; i++) {
                        name += chars.charAt(Math.floor(Math.random() * chars.length));
                    }
                } while (usedNames.has(name));
                
                usedNames.add(name);
                return name;
            }
            
            // 为变量创建映射
            localVars.forEach(varName => {
                varMap[varName] = generateObfName(varName);
            });
            
            functions.forEach(funcName => {
                varMap[funcName] = generateObfName(funcName);
            });
            
            // 应用变量名替换
            Object.keys(varMap).forEach(varName => {
                const regex = new RegExp(`\\b${varName}\\b`, 'g');
                obfuscated = obfuscated.replace(regex, varMap[varName]);
            });
            
            // 移除多余的空格和换行
            obfuscated = obfuscated.replace(/\s+/g, ' ').trim();
            
            // 添加随机混淆层
            obfuscated = `-- Obfuscated by Roblox Lua Obfuscator\n-- Generated on: ${new Date().toLocaleString()}\n\n` + obfuscated;
            
            return obfuscated;
        }
        
        // 显示通知
        function showNotification(message, type = 'success') {
            const notification = document.getElementById('notification');
            const notificationText = document.getElementById('notificationText');
            
            notificationText.textContent = message;
            
            if (type === 'error') {
                notification.style.backgroundColor = '#dc2626';
            } else {
                notification.style.backgroundColor = '#059669';
            }
            
            notification.classList.add('show');
            
            setTimeout(() => {
                notification.classList.remove('show');
            }, 3000);
        }
        
        // 转义HTML特殊字符
        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
        
        // 初始化事件监听器
        document.addEventListener('DOMContentLoaded', function() {
            // 初始化数据库
            initDB();
            
            // 获取DOM元素
            const fileInput = document.getElementById('fileInput');
            const uploadArea = document.getElementById('uploadArea');
            const codeInput = document.getElementById('codeInput');
            const codeOutput = document.getElementById('codeOutput');
            const obfuscateBtn = document.getElementById('obfuscateBtn');
            const clearBtn = document.getElementById('clearBtn');
            const copyBtn = document.getElementById('copyBtn');
            const downloadBtn = document.getElementById('downloadBtn');
            const adminBtn = document.getElementById('adminBtn');
            const adminPanel = document.getElementById('adminPanel');
            const refreshAdminBtn = document.getElementById('refreshAdminBtn');
            const clearAllBtn = document.getElementById('clearAllBtn');
            const closeAdminBtn = document.getElementById('closeAdminBtn');
            const loadingIndicator = document.getElementById('loadingIndicator');
            const resultTitle = document.getElementById('resultTitle');
            const charCount = document.getElementById('charCount');
            
            // 文件上传区域点击事件
            uploadArea.addEventListener('click', () => {
                fileInput.click();
            });
            
            // 拖放文件支持
            uploadArea.addEventListener('dragover', (e) => {
                e.preventDefault();
                uploadArea.style.backgroundColor = '#2d3748';
                uploadArea.style.borderColor = '#7c3aed';
            });
            
            uploadArea.addEventListener('dragleave', () => {
                uploadArea.style.backgroundColor = '';
                uploadArea.style.borderColor = '#4f46e5';
            });
            
            uploadArea.addEventListener('drop', (e) => {
                e.preventDefault();
                uploadArea.style.backgroundColor = '';
                uploadArea.style.borderColor = '#4f46e5';
                
                if (e.dataTransfer.files.length > 0) {
                    const file = e.dataTransfer.files[0];
                    if (file.name.endsWith('.lua') || file.name.endsWith('.luau')) {
                        readFile(file);
                    } else {
                        showNotification('请上传.lua或.luau文件', 'error');
                    }
                }
            });
            
            // 文件选择事件
            fileInput.addEventListener('change', () => {
                if (fileInput.files.length > 0) {
                    const file = fileInput.files[0];
                    readFile(file);
                }
            });
            
            // 读取文件内容
            function readFile(file) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    codeInput.value = e.target.result;
                    updateCharCount();
                    showNotification(`已加载文件: ${file.name}`);
                };
                reader.readAsText(file);
            }
            
            // 更新字符计数
            function updateCharCount() {
                const inputText = codeInput.value;
                const outputText = codeOutput.value;
                
                if (outputText) {
                    charCount.textContent = `${outputText.length} 字符`;
                } else {
                    charCount.textContent = `${inputText.length} 字符`;
                }
            }
            
            // 代码输入事件
            codeInput.addEventListener('input', updateCharCount);
            
            // 混淆按钮点击事件
            obfuscateBtn.addEventListener('click', () => {
                const inputCode = codeInput.value.trim();
                
                if (!inputCode) {
                    showNotification('请输入或上传Lua代码', 'error');
                    return;
                }
                
                // 显示加载指示器
                loadingIndicator.classList.add('active');
                resultTitle.textContent = '正在混淆...';
                
                // 模拟混淆过程（实际中可能更复杂）
                setTimeout(() => {
                    const obfuscatedCode = obfuscateLuaCode(inputCode);
                    codeOutput.value = obfuscatedCode;
                    
                    // 保存到数据库
                    saveCode(inputCode, obfuscatedCode);
                    
                    // 更新UI
                    resultTitle.textContent = '混淆完成';
                    updateCharCount();
                    
                    // 隐藏加载指示器
                    loadingIndicator.classList.remove('active');
                    
                    showNotification('代码混淆完成并已保存到后台');
                }, 800);
            });
            
            // 清空按钮点击事件
            clearBtn.addEventListener('click', () => {
                if (codeInput.value.trim() !== '' && !confirm('确定要清空代码吗？')) {
                    return;
                }
                
                codeInput.value = '';
                codeOutput.value = '';
                resultTitle.textContent = '等待混淆...';
                charCount.textContent = '0 字符';
                showNotification('已清空代码');
            });
            
            // 复制按钮点击事件
            copyBtn.addEventListener('click', () => {
                if (!codeOutput.value.trim()) {
                    showNotification('没有可复制的代码', 'error');
                    return;
                }
                
                codeOutput.select();
                document.execCommand('copy');
                
                // 取消选择文本
                window.getSelection().removeAllRanges();
                
                showNotification('代码已复制到剪贴板');
            });
            
            // 下载按钮点击事件
            downloadBtn.addEventListener('click', () => {
                const code = codeOutput.value;
                
                if (!code.trim()) {
                    showNotification('没有可下载的代码', 'error');
                    return;
                }
                
                const blob = new Blob([code], { type: 'text/plain' });
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = `obfuscated_${Date.now()}.lua`;
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                URL.revokeObjectURL(url);
                
                showNotification('代码已下载');
            });
            
            // 后台按钮点击事件
            adminBtn.addEventListener('click', () => {
                adminPanel.classList.add('active');
                loadAdminCodeList();
            });
            
            // 刷新后台按钮
            refreshAdminBtn.addEventListener('click', () => {
                loadAdminCodeList();
                showNotification('后台列表已刷新');
            });
            
            // 清除所有记录按钮
            clearAllBtn.addEventListener('click', clearAllScripts);
            
            // 关闭后台按钮
            closeAdminBtn.addEventListener('click', () => {
                adminPanel.classList.remove('active');
            });
            
            // 初始更新字符计数
            updateCharCount();
        });
    </script>
</body>
</html>
