# Agentic RAG Azure (Python)

Production-ready starter for an Agentic RAG platform on Azure.

## Day 1 Step 1 Baseline
- FastAPI service with health endpoint
- Package and test scaffold
- Strict lint/type/test tooling configuration

## Project Structure
- `src/api`: API entrypoint and routes
- `src/agent`: Agent orchestration
- `src/retrieval`: Retrieval services
- `src/ingestion`: Ingestion pipelines
- `src/guardrails`: Policy and guardrails
- `src/observability`: Telemetry and tracing
- `tests`: Unit, integration, and security tests
- `infra`: Infrastructure templates and scripts
- `scripts`: Utility scripts

## Local Run
1. Activate environment:
   - PowerShell: `.\\.venv\\Scripts\\Activate.ps1`
2. Install dependencies:
   - `pip install -e .[dev]`
3. Run tests:
   - `pytest`
4. Start API:
   - `uvicorn src.api.main:app --reload`
5. Health check:
   - `http://127.0.0.1:8000/api/v1/health`
