#!/bin/bash
echo "Setting up OCaml environment for vscode user..."

# Defina a versão do OCaml que você deseja usar
OCAML_VERSION="4.14.0"
# Ou use uma versão mais recente: OCAML_VERSION="5.1.1"

# Garante que estamos no diretório home do usuário para opam init
cd /home/vscode || exit

# Inicializa o opam para o usuário vscode.
# '--disable-sandboxing' é frequentemente necessário em containers.
# '-a' responde sim automaticamente para modificação de scripts de shell (ex: .bashrc)
opam init --disable-sandboxing -y -a

# Cria o switch OCaml se ele não existir
# Usar '|| true' para não falhar se o switch já existir de um rebuild anterior
opam switch create $OCAML_VERSION -y || true
# Garante que estamos usando o switch correto
opam switch $OCAML_VERSION

# Certifica-se que o ambiente opam está carregado para os próximos comandos
eval $(opam env)

echo "OCaml environment setup complete."
echo "Execute 'eval \$(opam env)' no seu terminal se os comandos ocaml/dune não forem encontrados."
echo "Ou reabra o terminal no VS Code."