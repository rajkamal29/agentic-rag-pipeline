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

## Azure Baseline Deployment
1. Authenticate with Azure CLI:
   - `az login`
2. Validate the Bicep template locally:
   - `./scripts/validate_infra.ps1`
3. Update `infra/main.parameters.json` with your naming and region values.
4. Deploy the baseline resources:
   - `./scripts/deploy_infra.ps1 -SubscriptionId <subscription-id> -ResourceGroupName <resource-group-name> -Location centralindia`

The baseline deploys:
- Log Analytics workspace
- Application Insights
- Azure Container Registry
- Azure Container Apps environment
- Azure Blob Storage with `documents` and `prompts` containers
- Azure AI Search
- Azure Key Vault
- User-assigned managed identity

## Repository Governance Baseline
1. Code owners are defined in `.github/CODEOWNERS`.
2. Validate branch protection payload (dry run):
   - `./scripts/set_branch_protection.ps1 -Owner <github-owner> -Repo <repo-name> -Branch main`
3. Apply branch protection to the repository:
   - `./scripts/set_branch_protection.ps1 -Owner <github-owner> -Repo <repo-name> -Branch main -Apply`

Default branch protection in the script enforces:
- required checks: `quality`, `dependency-audit`, `codeql`
- 1 required approving review
- required code owner reviews
- stale review dismissal
- no force push / no branch deletion
- linear history and conversation resolution
