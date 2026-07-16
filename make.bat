@echo off
setlocal enabledelayedexpansion

REM Check if virtual environment is active
if not defined VIRTUAL_ENV (
    echo ERROR: Virtual environment must be activated first!
    echo Please run: .venv\Scripts\activate.bat
    exit /b 1
)

REM Check if uv is available
where uv >nul 2>nul
if %errorlevel% equ 0 (
    set "UV=uv"
) else (
    set "UV="
)

REM Parse the target
set TARGET=%1
if "%TARGET%"=="" set TARGET=help

goto %TARGET%

:help
echo Available targets (venv must be created and activated first):
echo   make install        - Install the package (uses uv if available, else pip)
echo   make install-dev    - Install with dev dependencies (uses uv if available, else pip)
echo   make langgraph-dev  - Run LangGraph dev server
echo   make test           - Run unit + integration tests
echo   make test-unit      - Run unit tests only (no LLM calls)
echo   make test-provider [openai^|anthropic^|nv_build] - Run live provider tests
echo   make test-integration - Run integration tests only (invokes full graph, may call LLMs)
echo   make test-cov       - Run tests with coverage report
echo   make lint           - Run linters (ruff only)
echo   make lint-fix       - Auto-fix lint errors with ruff
echo   make format         - Format code with ruff
echo   make format-check   - Check code formatting with ruff
echo   make clean          - Remove build artifacts and cache files
echo   make build          - Build the package
echo   make docker-build   - Build the Docker image
echo   make docker-smoke   - Build and smoke test the Docker image
goto :eof

:install
if defined UV (
    echo Using uv sync...
    uv sync
) else (
    echo Using pip install -e . ...
    pip install -e .
)
goto :eof

:install-dev
if defined UV (
    echo Using uv sync --all-extras...
    uv sync --all-extras
) else (
    echo Using pip install -e ".[dev]" ...
    pip install -e ".[dev]"
)
goto :eof

:langgraph-dev
langgraph dev --studio-url https://smith.langchain.com
goto :eof

:test
call :test-unit
call :test-integration
goto :eof

:test-unit
pytest -m "not integration and not provider" tests/
goto :eof

:test-provider
set PROVIDER_TEST_TARGETS=tests/provider
if not "%2"=="" (
    set PROVIDER_TEST_TARGETS=
    if "%2"=="openai" set PROVIDER_TEST_TARGETS=tests/provider/test_provider_endpoint.py::test_openai_provider_makes_live_structured_request
    if "%2"=="anthropic" set PROVIDER_TEST_TARGETS=tests/provider/test_provider_endpoint.py::test_anthropic_provider_makes_live_structured_request
    if "%2"=="nv_build" set PROVIDER_TEST_TARGETS=tests/provider/test_provider_endpoint.py::test_nv_build_provider_makes_live_structured_request
    if "!PROVIDER_TEST_TARGETS!"=="" (
        echo ERROR: Invalid provider. Use openai, anthropic, or nv_build
        exit /b 1
    )
)

echo Running provider tests...
pytest -m provider !PROVIDER_TEST_TARGETS!
goto :eof

:test-integration
pytest -m integration tests/
goto :eof

:test-cov
pytest -m "not integration and not provider" --cov=src/skillspector --cov-report=html --cov-report=term-missing tests/
goto :eof

:test-ci
pytest -m "not integration and not provider" --cov=src/skillspector --cov-report=term-missing --cov-report=xml tests/
goto :eof

:lint
echo Running ruff...
ruff check src/ tests/
goto :eof

:lint-fix
echo Running ruff with auto-fix...
ruff check --fix src/ tests/
goto :eof

:format
echo Formatting with ruff...
ruff check --fix src/ tests/
ruff format src/ tests/
goto :eof

:format-check
echo Checking formatting with ruff...
ruff format --check src/ tests/
goto :eof

:clean
echo Cleaning build artifacts...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
for /d %%i in (src\*.egg-info) do rmdir /s /q "%%i"
if exist .pytest_cache rmdir /s /q .pytest_cache
if exist .ruff_cache rmdir /s /q .ruff_cache
if exist .mypy_cache rmdir /s /q .mypy_cache
if exist htmlcov rmdir /s /q htmlcov
if exist .coverage del /q .coverage
for /d /r . %%d in (__pycache__) do @if exist "%%d" rmdir /s /q "%%d"
for /r . %%f in (*.pyc) do @if exist "%%f" del /q "%%f"
echo Clean complete!
goto :eof

:build
call :clean
python -m build
goto :eof

:docker-build
docker build -t skillspector .
goto :eof

:docker-smoke
call :docker-build
tests\docker\smoke.sh
goto :eof

:openai
:anthropic
:nv_build
REM These are no-op targets in Makefile
goto :eof

:langgraph-dev
langgraph dev --studio-url https://smith.langchain.com
goto :eof