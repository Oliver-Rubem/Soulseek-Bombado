@echo off
set msg=
set /p msg="Sua mensagem (Enter para padrao): "

if "%msg%"=="" set msg=update: correcoes de seguranca e interface neon

echo ------------------------------------------
echo 1. Adicionando arquivos...
git add .

echo 2. Criando versao (Commit)...
git commit -m "%msg%"

echo 3. Ajustando branch para main...
git branch -M main

echo 4. Enviando para o GitHub...
git push -u origin main
echo ------------------------------------------

echo ✅ Finalizado!
pause
