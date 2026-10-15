.PHONY: help sync format lint typecheck test check clean

help: ## Mostra os comandos disponíveis
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}'

sync: ## Instala as dependências e sincroniza o ambiente virtual
	uv sync

format: ## Formata o código e corrige imports automaticamente
	uv run ruff check --fix .
	uv run ruff format .

lint: ## Verifica estilo, segurança e complexidade (sem alterar arquivos)
	uv run ruff check .
	uv run ruff format --check .

typecheck: ## Verifica a tipagem estática com Mypy
	uv run mypy .

test: ## Roda os testes com pytest e cobertura
	uv run pytest --cov=src --cov-report=term-missing --cov-branch

check: lint typecheck test ## Roda todas as verificações de qualidade (ideal para CI/CD)

clean: ## Remove caches e arquivos temporários
	rm -rf .venv .pytest_cache .mypy_cache .ruff_cache .coverage dist build
	find . -type d -name "__pycache__" -exec rm -rf {} +