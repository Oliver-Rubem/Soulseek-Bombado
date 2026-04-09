import webview
import json
import os
import sys
import subprocess
import threading

if getattr(sys, 'frozen', False):
    ROOT_DIR = os.path.dirname(sys.executable)
else:
    ROOT_DIR = os.path.dirname(os.path.abspath(__file__))

CONFIG_FILE = os.path.join(ROOT_DIR, "config.json")

class Api:
    def __init__(self):
        self.window = None

    def set_window(self, window):
        self.window = window

    def get_config(self):
        if os.path.exists(CONFIG_FILE):
            try:
                with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except Exception as e:
                return {"error": str(e)}
        return {}

    def save_config(self, data):
        try:
            with open(CONFIG_FILE, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=4)
            return {"success": True}
        except Exception as e:
            return {"error": str(e)}

    def select_folder(self):
        if self.window:
            result = self.window.create_file_dialog(webview.FOLDER_DIALOG)
            if result:
                return result[0]
        return None

    def run_download(self, method, url, download_dir):
        config = self.get_config()
        if "error" not in config:
            config["download_dir"] = download_dir
            self.save_config(config)

        script_dir = os.path.join(ROOT_DIR, "scripts")
        methods_map = {
            "soulseek": "soulseek.ps1",
            "spotdl": "spotdl.ps1",
            "hybrid": "hybrid.ps1"
        }
        
        script_name = methods_map.get(method.lower())
        if not script_name:
            return {"error": "Método desconhecido."}
        
        script_path = os.path.join(script_dir, script_name)
        
        threading.Thread(target=self._execute_script, args=(script_path, url, download_dir), daemon=True).start()
        return {"success": True, "message": f"Download via {method} iniciado!"}
        
    def _execute_script(self, script_path, url, download_dir):
        try:
            if self.window:
                self.window.evaluate_js(f"window.addLog('Iniciando script: {os.path.basename(script_path)}');")
                
            cmd = [
                "powershell",
                "-ExecutionPolicy", "Bypass",
                "-WindowStyle", "Hidden",
                "-File", script_path,
                "-Url", url,
                "-OutputPath", download_dir
            ]
            
            # Hide console window of child process on windows
            startupinfo = None
            if os.name == 'nt':
                startupinfo = subprocess.STARTUPINFO()
                startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
            
            process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, encoding='utf-8', errors='replace', startupinfo=startupinfo)
            
            for line in process.stdout:
                line = line.strip().replace('\\', '\\\\').replace('"', '\\"').replace("'", "\\'")
                if line and self.window:
                    self.window.evaluate_js(f"window.addLog('{line}');")
            
            process.wait()
            if self.window:
                if process.returncode == 0:
                    self.window.evaluate_js(f"window.addLog('✅ Finalizado com sucesso!');")
                else:
                    self.window.evaluate_js(f"window.addLog('❌ Processo retornou erro: {process.returncode}');")
                    
        except Exception as e:
            if self.window:
                error_msg = str(e).replace('\\', '\\\\').replace('"', '\\"').replace("'", "\\'")
                self.window.evaluate_js(f"window.addLog('❌ Exceção: {error_msg}');")

if __name__ == '__main__':
    api = Api()
    html_path = os.path.join(ROOT_DIR, 'interface', 'index.html')
    window = webview.create_window(
        'Soulseek Bombado [+]', 
        html_path, 
        js_api=api,
        width=900, 
        height=650,
        background_color='#000000',
        resizable=True
    )
    api.set_window(window)
    webview.start(debug=False)
