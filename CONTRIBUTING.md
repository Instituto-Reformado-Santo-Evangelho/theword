# 📝 Guia de Contribuição

> Este documento descreve como contribuir para o projeto The Word como editor ou revisor.

## 🎯 Objetivo do Projeto

O projeto The Word visa converter o conteúdo do livro "**O Soberano Criador Já Falou**" para módulos de Bíblia TheWord, mantendo a fidelidade ao texto original e corrigindo erros de digitação com o devido consentimento.

## 👥 Tipos de Contribuição

### 📖 Editor

Editores são responsáveis por:
- [RASCUNHO] Converter capítulos do PDF para formato texto
- [RASCUNHO] Adicionar marcações de versículos e referências
- [RASCUNHO] Inserir notas de rodapé no formato adequado
- [RASCUNHO] Garantir formatação consistente

**Requisitos:**
- [RASCUNHO] Conhecimento básico de Perl
- [RASCUNHO] Atenção aos detalhes
- [RASCUNHO] Familiaridade com estrutura bíblica

### 🔍 Revisor

Revisores são responsáveis por:
- [RASCUNHO] Verificar fidelidade ao texto original
- [RASCUNHO] Identificar erros de digitação
- [RASCUNHO] Validar referências e notas
- [RASCUNHO] Confirmar formatação correta

**Requisitos:**
- [RASCUNHO] Conhecimento do texto bíblico
- [RASCUNHO] Capacidade de análise crítica
- [RASCUNHO] Atenção aos detalhes

## 🛠️ Ferramentas e Ambiente

### Estrutura do Projeto

```
theword/
├── modules/bible/f35/     # Módulos da Bíblia
│   ├── F35.nt            # Arquivo principal
│   ├── Mt.nt             # Mateus (concluído)
│   ├── Mc.nt             # Marcos (concluído)
│   └── Lc.nt             # Lucas (concluído)
├── perl/                  # Scripts de conversão
│   ├── index.pl          # Script principal
│   ├── merged-main.pl    # Script de merge
│   └── lib/              # Bibliotecas
└── input-*.txt           # Arquivos de entrada
```

### Scripts Disponíveis

**[RASCUNHO]** Documentação dos scripts:
- `perl/index.pl` - [completar descrição]
- `perl/merged-main.pl` - [completar descrição]

## 📋 Processo de Contribuição

### Para Editores

1. [RASCUNHO] Escolher um livro/capítulo para trabalhar
2. [RASCUNHO] Preparar arquivo de entrada
3. [RASCUNHO] Executar scripts de conversão
4. [RASCUNHO] Revisar output gerado
5. [RASCUNHO] Submeter pull request

### Para Revisores

1. [RASCUNHO] Escolher um módulo para revisar
2. [RASCUNHO] Comparar com texto original
3. [RASCUNHO] Documentar correções necessárias
4. [RASCUNHO] Submeter relatório ou pull request

## ✅ Checklist de Qualidade

### Para Novos Módulos

- [ ] [RASCUNHO] Todos os versículos estão numerados
- [ ] [RASCUNHO] Notas estão corretamente referenciadas
- [ ] [RASCUNHO] Formatação está consistente
- [ ] [RASCUNHO] Títulos e subtítulos incluídos
- [ ] [RASCUNHO] Comparação com PDF original

### Para Revisões

- [ ] [RASCUNHO] Fidelidade ao texto verificada
- [ ] [RASCUNHO] Erros de digitação corrigidos
- [ ] [RASCUNHO] Referências validadas
- [ ] [RASCUNHO] Testes de módulo executados

## 📞 Contato e Suporte

**[RASCUNHO]** Informações de contato a serem adicionadas:
- Canal de comunicação principal
- Forma de reportar problemas
- Como obter acesso ao material original

## 📜 Diretrizes Gerais

1. **Fidelidade ao Original**: Manter-se fiel ao texto original do livro "O Soberano Criador Já Falou"
2. **Correções Autorizadas**: Apenas correções de erros de digitação com consentimento do Dr. Wilbur Pickering
3. **Consistência**: Seguir padrões estabelecidos nos módulos já concluídos (Mt, Mc, Lc)
4. **Documentação**: Documentar todas as correções realizadas

## 🔄 Fluxo de Trabalho

**[RASCUNHO]** A ser completado:
- Processo de atribuição de tarefas
- Sistema de revisão por pares
- Critérios de aprovação
- Ciclo de feedback

---

> **Nota**: Este documento está em desenvolvimento. Seções marcadas com [RASCUNHO] serão completadas posteriormente com informações mais detalhadas.
