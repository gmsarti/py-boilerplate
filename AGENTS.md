# AGENTS.md / CLAUDE.md — GUIDELINES

Guia para agentes de IA que vão trabalhar neste projeto (`py-boilerplate`). Leia antes de criar ou modificar qualquer coisa.

## Antes de Começar

Antes de iniciar qualquer implementação, verifique a branch atual. Evite trabalhar em `main`, `staging` ou `develop`; crie uma nova branch seguindo as convenções em [commit-rules.md](commit-rules.md).

**Tasks pontuais** (uma implementação focada que termina em um ciclo): todo commit exige autorização. Mesmo que já tenha commitado várias vezes na mesma sessão, **nunca assuma que a autorização se repete**. Após cada implementação, rode `make check` e pergunte sobre o commit.

**Tasks longas e complexas** (múltiplas etapas com validações intermediárias): se necessário, comite as evoluções ao longo da implementação e, ao concluir tudo, pergunte sobre o push e o PR ou siga as regras estipuladas para isso.

## Filosofia

**KISS — Keep It Simple, Stupid.** Toda decisão de código deve favorecer a solução mais simples que resolve o problema. Não adicione abstrações, configurabilidade ou generalização antecipada. Prefira nomes claros, estrutura óbvia e comentários onde a lógica não é autoevidente a soluções "inteligentes" que exigem decifração.

Regras práticas que derivam disso:

- Prefira **funções a classes** — só use classes quando houver estado real a manter (ou `dataclass`/`NamedTuple` para dados puros)
- Funções devem ser **sempre 100% tipadas** (parâmetros e retorno, exigido pelo `mypy --strict`)
- Use **early return** para evitar aninhamento desnecessário e manter a complexidade ciclomática baixa (McCabe <= 10)
- **Código mínimo que resolve o problema. Nada especulativo.**

**Toque só o que precisa. Limpe só a sua bagunça.** Esta é uma regra de escopo, não de estilo. Altere apenas o que é necessário para cumprir a tarefa. Não refatore código adjacente, não renomeie variáveis fora do problema, não faça "melhorias" oportunistas. Se você introduziu algo, você organiza. O resto fica como estava.

**Seja honesto — nunca invente.** Se não sabe, diga diretamente e aponte o que precisa verificar. Se está em dúvida, consulte a fonte (código, documentação, testes) antes de afirmar. Nunca entregue uma resposta plausível no lugar de uma correta.

**Não assuma — pergunte.** Se durante a implementação bater em um problema que não tem certeza de como resolver, pare e pergunte. Não adivinhe o caminho. Descreva o bloqueio, mostre as opções se houver, e deixe o time decidir.

**Tente antes de interromper — mas saiba a hora de parar.** Se uma tentativa falhar e a correção não exigir tocar em nada fora do escopo da tarefa, tente novamente. Até 2-3 tentativas são aceitáveis sem avisar. Depois disso, pare.

**Quando travar de verdade — pare e explique.** Interrompa imediatamente (sem esperar o limite de tentativas) se o bloqueio for externo à tarefa:

- precisa alterar arquivo ou módulo fora do escopo
- depende de algo fora do seu controle (config, variável de ambiente, serviço, permissão)
- exige uma decisão de design que impacta outras partes do sistema
- a tentativa quebrou código que já funcionava

Ao parar: descreva o bloqueio e sugira 1-2 opções de caminho. Sem histórico de tentativas — direto ao ponto. **Exceção:** ao iniciar uma tarefa, pergunte ao usuário se prefere ser notificado a cada bloqueio ou se quer que você tente resolver de forma autônoma até o fim — e siga a preferência declarada durante toda aquela sessão.

**Ao concluir uma implementação planejada — registre o resultado.** Escreva um resumo curto do que foi feito e se houve desvios do plano.

## Como Manter Este Arquivo

Este arquivo é o índice global do projeto — contém só o que vale para **todo** o código. Regras técnicas de um subpacote específico ficam no `AGENTS.md`/`CLAUDE.md` interno daquela pasta (`src/py_boilerplate/<modulo>/`).

- Máximo de **200 linhas** — se ultrapassar, mova conteúdo para o sub-arquivo do módulo
- Nunca adicione blocos de código longos neste arquivo
- **Antes de planejar:** consulte os arquivos de diretrizes internos de cada módulo que será modificado

## Arquivos Auxiliares

- [`commit-rules.md`](commit-rules.md) — regras de commit, branch, push e PR
- [`README.md`](README.md) — visão geral e comandos básicos do projeto

## Arquitetura em Uma Linha

Pacote Python 3.11+ minimalista gerenciado via `uv` (`uv_build`), usando `src-layout` (`src/py_boilerplate/`), validação estrita com `Ruff` + `Mypy (strict)` e testes com `Pytest`.

## Mapa de Arquivos Críticos

- `pyproject.toml` — fonte única de verdade para dependências, build (`uv_build`) e configs do Ruff, Mypy e Pytest
- `Makefile` — atalhos padronizados para automação e verificação de qualidade
- `tests/` — suíte de testes espelhando a estrutura de `src/`

## Como Adicionar uma Feature

1. **Implementação** — crie funções/módulos pequenos e tipados em `src/py_boilerplate/`
2. **Exportação** — se fizer parte da API pública ou CLI, exponha em `__init__.py`
3. **Testes** — crie testes unitários correspondentes em `tests/test_<modulo>.py`
4. **Formatação e Qualidade** — rode `make format` e depois `make check` (zero erros tolerados)

## Como Rodar o Projeto

Sempre execute ferramentas através do `uv run` ou do `Makefile` (nunca invoque `python`, `pytest` ou `pip` globalmente):

- `make sync` — instala dependências e sincroniza o `.venv` via `uv`
- `make format` — formata código e organiza imports (`ruff`)
- `make check` — roda `lint` + `typecheck` (`mypy`) + `test` (`pytest` com coverage)
- `uv run py-boilerplate` — executa o entrypoint do projeto

## Convenções de Nomenclatura (PEP 8)

| Elemento | Convenção | Exemplo |
| :--- | :--- | :--- |
| Módulos e Arquivos | `snake_case` | `data_parser.py` |
| Funções e Variáveis | `snake_case` | `calculate_total()`, `user_id` |
| Classes / Exceptions / TypeAliases | `PascalCase` | `ValidationError`, `UserConfig` |
| Constantes Globais | `UPPER_SNAKE_CASE` | `MAX_RETRIES`, `DEFAULT_TIMEOUT` |
| Arquivos e Funções de Teste | `test_<alvo>` | `tests/test_parser.py`, `def test_empty_input() -> None:` |

## Regras Globais do Código Python

### Tipagem e Sintaxe Moderna (Python 3.11+)

- **Mypy Strict:** Todas as funções (incluindo testes) devem ter tipos de entrada e saída (`-> None`, `-> str`, etc.).
- **Sintaxe nativa (Regra `UP`):** Use `list[str]`, `dict[str, int]` e `X | None` em vez de `List`, `Dict` ou `Optional` do módulo `typing`.
- **Proibido `Any` implícito:** Evite `Any`. Se precisar lidar com estruturas dinâmicas, use `TypedDict`, `Protocol` ou `dataclass`.

### Complexidade e Estilo (Ruff)

- **Limite McCabe (`C90`):** A complexidade ciclomática máxima por função é **10**. Se o Ruff acusar `C901`, quebre a função em funções auxiliares menores.
- **Estilo Pytest (`PT`):** Use fixtures e `pytest.raises(Erro, match="...")`. Nos testes, `assert` padrão é permitido (`S101` ignorado apenas em `tests/**`).

### Testes e Avisos

- **Zero Warnings:** O Pytest está configurado com `filterwarnings = ["error"]`. Qualquer `DeprecationWarning` ou aviso de biblioteca quebrará os testes.
- **Cobertura:** Toda nova lógica deve manter a cobertura de linhas e branches (`--cov-branch`).

### Segurança (Bandit / Regra `S`)

- Nunca faça hardcode de senhas, tokens ou chaves no código (`S105`/`S106`).
- Nunca use `eval()`, `exec()`, `pickle` para dados não confiáveis, ou `subprocess` com `shell=True`.
- Sempre defina `timeout=` em chamadas de rede/HTTP (`S113`).

## O que NÃO Fazer

- **Não use `pip install` ou `poetry`** — use exclusivamente `uv add <pacote>` ou `uv add --dev <pacote>`
- **Não crie arquivos de config soltos** (`.flake8`, `pytest.ini`, `mypy.ini`, `requirements.txt`) — tudo fica centralizado no `pyproject.toml`
- **Não silencie o linter/typechecker sem motivo** — nunca adicione `# noqa` ou `# type: ignore` sem especificar o código exato do erro (ex: `# type: ignore[arg-type]`) e um comentário curto explicando o porquê
- **Não use argumentos padrão mutáveis** (`def fn(items: list[str] = [])`) — o Ruff (`B006`) bloqueará; use `None` como padrão
- **Não use `assert` dentro de `src/`** para validação de negócio (ele é removido se o Python rodar com `-O` e viola a regra `S101` do Bandit) — levante exceções explícitas (`ValueError`, `TypeError`)
