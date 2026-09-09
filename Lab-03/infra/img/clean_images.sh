#!/bin/bash

# Caminho para o arquivo Markdown
MARKDOWN_FILE="../README.md"

# Diretório onde as imagens estão localizadas
IMAGE_DIR="./img"

# Obter a lista de imagens referenciadas no arquivo Markdown
referenced_images=$(awk -F'[()]' '/!\[.*\]\(.*\.png\)/ {print $2}' "$MARKDOWN_FILE" | grep './img/' | sed 's|./img/||')

# Navegar para o diretório das imagens
cd "$IMAGE_DIR" || exit

# Iterar sobre os arquivos no diretório
for file in *; do
  # Verificar se o arquivo não está na lista de imagens referenciadas
  if [[ ! "$referenced_images" =~ $file ]]; then
    # Remover o arquivo
    echo "Removendo: $file"
    rm -v "$file"
  fi
done

echo "Limpeza concluída. Apenas as imagens referenciadas foram mantidas."