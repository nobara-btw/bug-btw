# 🐧 Nobara Linux Utilities

[![Linux](https://img.shields.io/badge/Linux-Nobara-blue?logo=linux&logoColor=white)](https://nobaraproject.org/)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/rufusg08/nobara-btw/graphs/commit-activity)

> 🛠️ Conjunto de scripts inteligentes para otimização e gerenciamento do sistema Nobara Linux

---

## 📋 Índice

- [Sobre](#-sobre)
- [Scripts Disponíveis](#-scripts-disponíveis)
  - [🧹 ck.sh - Clean Kernel](#-cksh---clean-kernel)
  - [📹 wc.sh - Webcam Controller](#-wcsh---webcam-controller)
- [Configurações EasyEffects](#-configurações-easyeffects)
- [Instalação](#-instalação)
- [Uso](#-uso)
- [Requisitos](#-requisitos)
- [Contribuindo](#-contribuindo)
- [Licença](#-licença)

---

## 🎯 Sobre

Este repositório contém uma coleção de scripts bash inteligentes e configurações otimizadas para usuários do **Nobara Linux**. Os scripts foram desenvolvidos com lógica avançada para automatizar tarefas comuns de manutenção do sistema e gerenciamento de hardware.

### ✨ Características

- 🚀 **Desempenho**: Scripts otimizados para execução rápida
- 🧠 **Inteligência**: Lógica adaptativa e verificações de segurança
- 🎨 **Interface**: Output colorido e informativo no terminal
- 🔒 **Segurança**: Verificações antes de operações críticas

---

## 🔧 Scripts Disponíveis

### 🧹 `ck.sh` - Clean Kernel

Script inteligente para limpeza profunda do kernel e sistema operacional Nobara.

#### Funcionalidades:
- ✅ Remove kernels antigos e não utilizados
- ✅ Limpa cache do sistema (DNF, PackageKit, etc.)
- ✅ Remove pacotes órfãos e dependências desnecessárias
- ✅ Limpa logs antigos do systemd
- ✅ Otimiza espaço em disco
- ✅ Mantém o sistema leve e funcional

#### Uso:
```bash
chmod +x ck.sh
./ck.sh
```

#### O que o script faz:
1. 🔍 Verifica kernels instalados
2. 🗑️ Remove kernels antigos (mantém o atual + 1 backup)
3. 🧹 Limpa cache do DNF e PackageKit
4. 📦 Remove pacotes órfãos
5. 📋 Limpa logs com mais de 7 days
6. 💾 Exibe espaço liberado

---

### 📹 `wc.sh` - Webcam Controller

Script inteligente para controle da webcam com funções de ativação/desativação.

#### Funcionalidades:
- ✅ Ativa/desativa webcam de forma segura
- ✅ Detecta automaticamente o dispositivo de webcam
- ✅ Verifica processos que estão usando a câmera
- ✅ Previne desativação acidental durante uso
- ✅ Status visual claro no terminal

#### Uso:
```bash
chmod +x wc.sh
./wc.sh
```

#### Opções:
```bash
./wc.sh   # Painel de Gerenciamento da Webcam
```

#### Recursos de Segurança:
- 🔒 Não permite desativação se a câmera estiver em uso
- 🔍 Detecta automaticamente drivers e módulos
- ⚠️ Avisos antes de operações críticas

---

## 🎵 Configurações EasyEffects

Perfis de áudio otimizados para EasyEffects (PulseEffects).

### 📁 Localização das Configurações
```
~/.var/app/com.github.wwmm.easyeffects/data/easyeffects/
files: "output" (Speaker) - "input" (Microphone)
```

### Perfis Incluídos:

#### 🎸 `CustomBass.json`
Perfil otimizado para realce de graves e qualidade de áudio em saídas.

**Características:**
- 🔊 Equalização customizada para graves profundos
- 🎛️ Compressor dinâmico para evitar distorção
- 🎚️ Limiter para proteção de alto-falantes
- 🎼 Ideal para música eletrônica, hip-hop e rock

**Instalação:**
```bash
cp CustomBass.json ~/.var/app/com.github.wwmm.easyeffects/data/easyeffects/output/
```

---

#### 🎤 `Mic.json`
Perfil otimizado para captura de áudio do microfone.

**Características:**
- 🎙️ Noise reduction avançado
- 🔇 Gate para eliminar ruído de fundo
- 📢 Compressor para voz uniforme
- 🎯 Equalização para clareza vocal
- 🎮 Ideal para streaming, podcasts e chamadas

**Instalação:**
```bash
cp Mic.json ~/.var/app/com.github.wwmm.easyeffects/data/easyeffects/input/
```

---

## 📥 Instalação

### Método 1: Clone do Repositório

```bash
# Clone o repositório
git clone https://github.com/rufusg08/nobara-btw.git

# Entre no diretório
cd nobara-btw

# Torne os scripts executáveis
chmod +x ck.sh wc.sh

# (Opcional) Copie as configurações do EasyEffects
cp CustomBass.json ~/.var/app/com.github.wwmm.easyeffects/data/easyeffects/output/
cp Mic.json ~/.var/app/com.github.wwmm.easyeffects/data/easyeffects/input/
```

### Método 2: Download Direto

```bash
# Download individual de scripts
wget https://raw.githubusercontent.com/yourusername/nobara-utilities/main/ck.sh
wget https://raw.githubusercontent.com/yourusername/nobara-utilities/main/wc.sh

chmod +x ck.sh wc.sh
```

---

## 🚀 Uso

### Limpeza do Sistema (Recomendado Semanalmente)

```bash
./ck.sh
```

### Controle da Webcam

```bash
# Abre o painel de gerenciamento
./wc.sh
```

### Aplicar Perfis de Áudio

1. Abra o EasyEffects
2. Vá em **Presets**
3. Selecione **CustomBass** para output ou **Mic** para input
4. Os perfis serão carregados automaticamente

---

## ⚙️ Requisitos

### Sistema Operacional
- 🐧 **Nobara Linux** (testado em versões 38+)
- 🔧 Também compatível com Fedora e derivados

### Dependências

#### Para `ck.sh`:
```bash
sudo dnf install dnf-utils
```

#### Para `wc.sh`:
```bash
sudo dnf install v4l-utils
```

#### Para EasyEffects:
```bash
flatpak install flathub com.github.wwmm.easyeffects
```

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:

1. 🍴 Fork o projeto
2. 🌟 Criar uma branch para sua feature (`git checkout -b feature/NovaFuncionalidade`)
3. 💾 Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. 📤 Push para a branch (`git push origin feature/NovaFuncionalidade`)
5. 🎉 Abrir um Pull Request

### 📝 Diretrizes

- Mantenha o código limpo e comentado
- Teste em Nobara Linux antes de submeter
- Atualize a documentação quando necessário
- Siga as boas práticas de bash scripting

---

## 📜 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 📞 Suporte

- 🐛 **Issues**: [GitHub Issues](https://github.com/rufusg08/nobara-btw/issues)
- 💬 **Discussões**: [GitHub Discussions](https://github.com/rufusg08/nobara-btw/discussions)

---

## 🙏 Agradecimentos

- **Nobara Project** - Pela excelente distribuição Linux
- **EasyEffects** - Pelo incrível processador de áudio
- Comunidade Linux - Pelo suporte e feedback contínuo

---

<div align="center">

**⭐ Se este projeto te ajudou, considere dar uma estrela! ⭐**

Feito com ❤️ para a comunidade Nobara Linux

[⬆ Voltar ao topo](#-nobara-linux-utilities)

</div>
