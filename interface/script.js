const consoleOutput = document.getElementById('console-output');

// Tabs logic
document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
        
        btn.classList.add('active');
        document.getElementById(`tab-${btn.dataset.tab}`).classList.add('active');
    });
});

window.addEventListener('pywebviewready', function() {
    // Load config
    pywebview.api.get_config().then(config => {
        if(!config.error) {
            document.getElementById('set-clientid').value = config.spotify_client_id || "";
            document.getElementById('set-clientsecret').value = config.spotify_client_secret || "";
            document.getElementById('set-slskuser').value = config.soulseek_username || "";
            document.getElementById('set-slskpass').value = config.soulseek_password || "";
            document.getElementById('download-path').value = config.download_dir || "Downloads";
            document.getElementById('set-download-path').value = config.download_dir || "Downloads";
        }
    });

    // Sincronizar campos de pasta de download
    const mainPath = document.getElementById('download-path');
    const settingsPath = document.getElementById('set-download-path');
    
    mainPath.addEventListener('input', () => { settingsPath.value = mainPath.value; });
    settingsPath.addEventListener('input', () => { mainPath.value = settingsPath.value; });
});

function browseFolder(targetId = 'download-path') {
    pywebview.api.select_folder().then(folder => {
        if (folder) {
            document.getElementById(targetId).value = folder;
            // Sincroniza o outro campo
            if (targetId === 'download-path') {
                document.getElementById('set-download-path').value = folder;
            } else {
                document.getElementById('download-path').value = folder;
            }
        }
    });
}

function addLog(msg) {
    const logEl = document.createElement('div');
    logEl.className = 'log';
    logEl.textContent = `> ${msg}`;
    consoleOutput.appendChild(logEl);
    consoleOutput.scrollTop = consoleOutput.scrollHeight;
}

function startDownload(method) {
    const url = document.getElementById('spotify-url').value.trim();
    if (!url) {
        addLog('❌ Erro: Insira um link válido do Spotify primeiro.');
        return;
    }
    const downloadDir = document.getElementById('download-path').value.trim() || 'Downloads';
    
    addLog(`⏳ Solicitando download via ${method}...`);
    pywebview.api.run_download(method, url, downloadDir).then(res => {
        if (res.error) addLog(`❌ Erro interno: ${res.error}`);
    });
}

function saveSettings() {
    const config = {
        spotify_client_id: document.getElementById('set-clientid').value.trim(),
        spotify_client_secret: document.getElementById('set-clientsecret').value.trim(),
        soulseek_username: document.getElementById('set-slskuser').value.trim(),
        soulseek_password: document.getElementById('set-slskpass').value.trim(),
        download_dir: document.getElementById('set-download-path').value.trim() || "Downloads"
    };

    pywebview.api.save_config(config).then(res => {
        const msg = document.getElementById('settings-msg');
        if (res.success) {
            msg.textContent = "Configurações salvas com sucesso!";
            setTimeout(() => msg.textContent = "", 3000);
        } else {
            msg.textContent = `Erro: ${res.error}`;
        }
    });
}
