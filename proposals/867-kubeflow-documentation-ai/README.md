# KEP-867: Kubeflow Documentation AI Assistant with Retrieval-Augmented Generation

## Summary

This KEP proposes the development of an AI-powered documentation assistant for the Kubeflow ecosystem that leverages Retrieval-Augmented Generation (RAG) to provide accurate, contextual, and cited responses to user queries.

The assistant will be deployed as a cloud-native solution on Kubernetes, utilizing KServe for model serving, Kubeflow Pipelines for automated indexing, and an agentic approach to intelligently route queries between foundational LLM knowledge and documentation-specific retrieval.

## Motivation

Kubeflow users currently face significant challenges in finding accurate information across fragmented sources:
- **Fragmented Knowledge Base**: Critical information is scattered across multiple repositories, GitHub issues, pull requests, documentation pages, and community discussions.
- **Manual Search Inefficiency**: Users must manually search through multiple sources, causing frustration and inefficiency.
- **Limited Search Capabilities**: The current website relies on basic Google Custom Search, limited to static content.
- **Knowledge Gap**: Many issues stem from underlying Kubernetes concepts that users expect to find in Kubeflow documentation.

The Kubeflow community's knowledge represents a valuable treasure trove of information that is currently underutilized due to accessibility challenges. By making this knowledge easily searchable and accessible through natural language queries, we can:
- Reduce time-to-value for new users.
- Decrease repetitive support requests.
- Improve overall user experience.
- Leverage the community's collective knowledge more effectively.

This proposal is related to the following issues:
- **KEP-867**: [Kubeflow Documentation AI Assistant with Retrieval-Augmented Generation · Issue #867 · kubeflow/community](https://github.com/kubeflow/community/issues/867)
- **website**: [Empowering Kubeflow Documentation with LLMs · Issue #4025 · kubeflow/website](https://github.com/kubeflow/website/issues/4025)

### Goals

- **Primary Goal**: Create an intelligent documentation assistant that can answer user queries using both foundational LLM knowledge and Kubeflow-specific documentation.
- **Accessibility**: Provide a single interface for accessing information across all Kubeflow repositories and documentation.
- **Accuracy**: Ensure responses are accurate, contextual, and properly cited.
- **Scalability**: Build a system that can scale with the growing Kubeflow ecosystem.
- **Maintainability**: Implement automated indexing to keep information current.
- **Community Integration**: Provide feedback mechanisms to continuously improve the system.

### Non-Goals

- Replace current documentation: This system complements existing documentation rather than replacing it.
- Implement a general-purpose chatbot: We intend to focus on Kubeflow-specific queries and related technologies.
- Operational debugging: We won't provide real-time debugging of user deployments.
- Training new LLMs: We will use existing pre-trained models.
- Multi-language support: Initial implementation will be English-only.
- Outdated Examples: Many code examples and tutorials become outdated as the project evolves.

## Proposal

The solution consists of two main workflows:
1.  **Document Indexing Pipeline**: An automated system for ingesting, processing, and indexing documentation from various sources like GitHub repositories, pull requests, and the official website.
2.  **Query-Answering Service**: A real-time service for handling user queries with intelligent routing between a foundational LLM and the indexed Kubeflow-specific knowledge.

## Design Details

The RAG-powered chatbot implementation consists of three core components that work together to provide intelligent, context-aware responses based on Kubeflow documentation:
- **LLM Deployment**: Model serving infrastructure using KServe.
- **Vector Database**: Document indexing and retrieval using Milvus.
- **Backend Service**: RAG orchestration and WebSocket API.

### 1. LLM Deployment with KServe

We use KServe to deploy and serve large language models in our Kubernetes cluster. KServe provides a standardized serving layer with automatic scaling, model versioning, and high availability.

**Model Serving Setup**

Create a secret with your Hugging Face token:
```yaml
apiVersion: v1
kind: Secret
metadata:
    name: hf-secret
type: Opaque    
stringData:
    HF_TOKEN: <your-huggingface-token>
```

Deploy the LLM using KServe InferenceService:
```yaml
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: huggingface-llama3
spec:
  predictor:
    model:
      modelFormat:
        name: huggingface
      args:
        - --model_name=llama3
        - --model_id=meta-llama/meta-llama-3-8b-instruct
      env:
        - name: HF_TOKEN
          valueFrom:
            secretKeyRef:
              name: hf-secret
              key: HF_TOKEN
      resources:
        limits:
          cpu: "6"
          memory: 24Gi
          nvidia.com/gpu: "1"
```

### 2. Vector Database with Feast + Milvus

Deploy Milvus using Helm:
```bash
helm repo add milvus https://milvus-io.github.io/milvus-helm/
helm install my-release milvus/milvus
```

**Document Indexing Pipeline (Kubeflow Pipelines Integration)**
```python
@component(
    base_image="python:3.9",
    packages_to_install=[
        "pymilvus==2.3.0",
        "sentence-transformers==2.2.2", 
        "gitpython==3.1.32"
    ]
)
def repo_indexing_component(
    repo_urls: list,
    milvus_host: str = "my-release-milvus",
    milvus_port: str = "19530",
    rebuild: bool = False
) -> dict:
    """Kubeflow component for repository indexing"""
    
    # Implementation includes:
    # - Repository cloning and file scanning
    # - Text chunking with 512 token chunks and 50% overlap
    # - Embedding generation using all-mpnet-base-v2
    # - Milvus collection creation and data insertion
    
    return {
        "status": "success",
        "total_chunks": total_chunks,
        "processed_repos": processed_repos
    }

@pipeline(name="kubeflow-docs-indexing-pipeline")
def indexing_pipeline(
    repo_urls: list = [
        "https://github.com/kubeflow/website",
        "https://github.com/kubeflow/kubeflow"
    ],
    rebuild: bool = False
):
    indexing_task = repo_indexing_component(
        repo_urls=repo_urls,
        rebuild=rebuild
    )
    return indexing_task.outputs
```

### 3. Backend Service

The backend service orchestrates the RAG workflow with WebSocket API for real-time responses.

**Key Features**:
- WebSocket API for real-time streaming responses.
- RAG Integration with automatic context retrieval from Milvus.
- Fallback Handling for queries without relevant context.
- Source Attribution showing which documents informed the response.

**Service Implementation (Simplified)**
```python
from fastapi import FastAPI, WebSocket
from pymilvus import MilvusClient
from sentence_transformers import SentenceTransformer

class RAGSearcher:
    def __init__(self, milvus_host="milvus-service", milvus_port="19530"):
        self.client = MilvusClient(uri=f"http://{milvus_host}:{milvus_port}")
        self.encoder = SentenceTransformer("all-mpnet-base-v2")
    
    def search(self, query: str, limit: int = 5) -> List[Dict]:
        query_vector = self.encoder.encode(query).tolist()
        # Search across collections and return formatted results
        return results

app = FastAPI()
rag_searcher = RAGSearcher()

@app.websocket("/ws")
async def ws(ws: WebSocket):
    await ws.accept()
    # Handle WebSocket communication and RAG processing
```

**Deployment Configuration**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rag-chatbot-backend
spec:
  replicas: 2
  template:
    spec:
      containers:
      - name: backend
        image: your-registry/rag-chatbot-backend:latest
        ports:
        - containerPort: 8000
        env:
        - name: MILVUS_HOST
          value: "my-release-milvus"
---
apiVersion: v1
kind: Service
metadata:
  name: rag-chatbot-service
spec:
  selector:
    app: rag-chatbot-backend
  ports:
  - port: 8000
    targetPort: 8000
```

### 4. GitHub Master branch ETL Pipeline

To keep the knowledge base current with the latest pull requests and discussions, we implement a daily ETL job that fetches PR data from GitHub's REST API.

**GitHub PR Fetcher Component**
```python
@component(
    base_image="python:3.9",
    packages_to_install=[
        "requests==2.31.0",
        "pymilvus==2.3.0",
        "sentence-transformers==2.2.2"
    ]
)
def github_pr_etl_component(
    github_token: str,
    repositories: list,
    milvus_host: str = "my-release-milvus",
    milvus_port: str = "19530",
    days_back: int = 7
) -> dict:
    """ETL component to fetch and index GitHub PRs"""
    
    import requests
    import json
    from datetime import datetime, timedelta
    from pymilvus import MilvusClient
    from sentence_transformers import SentenceTransformer
    
    # Initialize clients
    client = MilvusClient(uri=f"http://{milvus_host}:{milvus_port}")
    encoder = SentenceTransformer("all-mpnet-base-v2")
    
    headers = {
        "Authorization": f"token {github_token}",
        "Accept": "application/vnd.github.v3+json"
    }
    
    total_prs = 0
    processed_repos = []
    
    # Calculate date threshold
    since_date = (datetime.now() - timedelta(days=days_back)).isoformat()
    
    for repo in repositories:
        print(f"Processing repository: {repo}")
        
        # Fetch recent PRs
        pr_url = f"https://api.github.com/repos/{repo}/pulls"
        params = {
            "state": "all",
            "since": since_date,
            "per_page": 100,
            "sort": "updated"
        }
        
        response = requests.get(pr_url, headers=headers, params=params)
        
        if response.status_code != 200:
            print(f"Failed to fetch PRs for {repo}: {response.status_code}")
            continue
            
        prs = response.json()
        repo_pr_count = 0
        
        # Process each PR
        for pr in prs:
            try:
                # Fetch PR details including diff
                pr_detail_url = f"https://api.github.com/repos/{repo}/pulls/{pr['number']}"
                detail_response = requests.get(pr_detail_url, headers=headers)
                pr_detail = detail_response.json()
                
                # Fetch PR comments
                comments_url = f"https://api.github.com/repos/{repo}/issues/{pr['number']}/comments"
                comments_response = requests.get(comments_url, headers=headers)
                comments = comments_response.json() if comments_response.status_code == 200 else []
                
                # Prepare PR content for indexing
                pr_content = f"""
                Title: {pr['title']}
                Description: {pr.get('body', '')}
                Author: {pr['user']['login']}
                State: {pr['state']}
                Created: {pr['created_at']}
                Updated: {pr['updated_at']}
                
                Comments:
                {' '.join([comment.get('body', '') for comment in comments[:5]])}
                """
                
                # Create embedding
                embedding = encoder.encode(pr_content).tolist()
                
                # Prepare data for Milvus
                pr_data = {
                    "id": int(f"{hash(repo + str(pr['number'])) % 1000000000}"),
                    "vector": embedding,
                    "repo_name": repo.split('/')[-1],
                    "pr_number": pr['number'],
                    "title": pr['title'],
                    "author": pr['user']['login'],
                    "state": pr['state'],
                    "content": pr_content[:2000],  # Truncate if too long
                    "url": pr['html_url'],
                    "created_at": pr['created_at'],
                    "updated_at": pr['updated_at']
                }
                
                # Insert into PR collection
                collection_name = f"pr_{repo.split('/')[-1].replace('-', '_').lower()}"
                
                # Create collection if it doesn't exist
                if not client.has_collection(collection_name):
                    client.create_collection(
                        collection_name=collection_name,
                        dimension=768,
                        metric_type="COSINE"
                    )
                
                client.insert(collection_name=collection_name, data=[pr_data])
                repo_pr_count += 1
                
            except Exception as e:
                print(f"Error processing PR {pr['number']}: {e}")
                continue
        
        # Flush collection
        if repo_pr_count > 0:
            client.flush(collection_name)
        
        total_prs += repo_pr_count
        processed_repos.append({
            "repo": repo,
            "pr_count": repo_pr_count
        })
        
        print(f"Processed {repo_pr_count} PRs from {repo}")
    
    return {
        "status": "success",
        "total_prs": total_prs,
        "processed_repos": processed_repos,
        "execution_date": datetime.now().isoformat()
    }

@pipeline(name="github-pr-etl-pipeline")
def github_pr_etl_pipeline(
    github_token: str,
    repositories: list = [
        "kubeflow/kubeflow",
        "kubeflow/website",
        "kubeflow/training-operator",
        "kubeflow/pipelines"
    ],
    days_back: int = 7
):
    """Daily ETL pipeline for GitHub PRs"""
    
    etl_task = github_pr_etl_component(
        github_token=github_token,
        repositories=repositories,
        days_back=days_back
    )
    
    return etl_task.outputs
```

**Scheduled Execution (CronJob)**
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: github-pr-etl
spec:
  schedule: "0 12 * * *"  # Run daily at 12:00 PM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: pr-etl
            image: your-registry/kfp-runner:latest
            command:
            - python
            - -c
            - |
              import kfp
              from github_pr_etl import github_pr_etl_pipeline
              
              client = kfp.Client(host='http://ml-pipeline:8888')
              
              run = client.run_pipeline(
                  experiment_id="github-etl",
                  job_name="daily-pr-sync",
                  pipeline_func=github_pr_etl_pipeline,
                  arguments={
                      "github_token": "$(GITHUB_TOKEN)",
                      "days_back": 1
                  }
              )
            env:
            - name: GITHUB_TOKEN
              valueFrom:
                secretKeyRef:
                  name: github-secret
                  key: token
          restartPolicy: OnFailure
```

**GitHub Token Secret**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: github-secret
type: Opaque
stringData:
  token: <your-github-personal-access-token>
```

**Enhanced RAG Search with PR Data**
```python
class EnhancedRAGSearcher(RAGSearcher):
    def search_with_prs(self, query: str, include_prs: bool = True) -> List[Dict]:
        """Search both documentation and PR data"""
        
        # Get regular documentation results
        doc_results = self.search(query, limit=3)
        
        if not include_prs:
            return doc_results
        
        # Search PR collections
        pr_results = []
        query_vector = self.encoder.encode(query).tolist()
        
        for collection in self.client.list_collections():
            if collection.startswith("pr_"):
                try:
                    results = self.client.search(
                        collection_name=collection,
                        data=[query_vector],
                        limit=2,
                        output_fields=["repo_name", "title", "author", "state", "url", "content"]
                    )
                    
                    for result in results[0]:
                        if (1 - result['distance']) > 0.4:  # Threshold for PR relevance
                            entity = result['entity']
                            pr_results.append({
                                'type': 'pull_request',
                                'repo_name': entity['repo_name'],
                                'title': entity['title'],
                                'author': entity['author'],
                                'state': entity['state'],
                                'url': entity['url'],
                                'content': entity['content'][:500],
                                'score': 1 - result['distance']
                            })
                except Exception as e:
                    continue
        
        # Combine and sort results
        combined_results = doc_results + pr_results
        combined_results.sort(key=lambda x: x['score'], reverse=True)
        
        return combined_results[:5]
```

### Implementation Plan

#### Phase 1: Repository Setup and Infrastructure Planning
- Create a new repository under the Kubeflow organization: `kubeflow/docs-bot`
- Define cloud resource requirements for:
  - LLM inference (GPU/CPU requirements for Llama 3.1 8B or Mistral 7B)
  - Milvus vector database deployment
  - Backend service hosting
- Establish project structure with clear separation of concerns:
  - `/milvus` - yaml files for deploying milvus
  - `/config` - Cluster configuration
  - `/backend` - API and WebSocket services
  - `/LLM` - LLM deployment and loading scripts.
  - `/tests` - Testing infrastructure.

#### Phase 2: Development and Testing
- Deploy and benchmark LLM locally (Llama 3.1 8B or Mistral 7B)
- Set up Milvus database and implement ETL pipeline starting with `website` repository
- Develop backend services (WebSocket, RAG pipeline, GitHub API integration)
- Implement security measures (RBAC, rate limiting, prompt injection protection)

#### Phase 3: Deployment and Integration
- Deploy complete stack to Kubernetes cluster with monitoring
- Integrate WebSocket with Kubeflow website and add UI/UX components
- Conduct community testing and launch docs bot

## Test Plan

The goal is to ensure that we don't accept enhancements with inadequate testing.
All code is expected to have adequate tests (eventually with coverage
expectations). Please adhere to the Kubeflow testing guidelines when drafting this test plan.

- **Automated LLM Response Testing**: Create predefined question set drafted by community. Run automated evaluation on every merge to validate response accuracy and consistency.
- **Performance Testing**: Target: < 5 seconds average response time. Monitor end-to-end pipeline and optimize bottlenecks. Load testing for concurrent users.
- **Security Testing**: RBAC enforcement validation. Prompt injection testing with guardrails. GitHub issue creation spam prevention with rate limiting.
- **User Feedback Validation**: Test thumbs up/down logging and GitHub issue creation. Community beta testing with selected members.

[ ] I/we understand the owners of the involved components may require updates to
existing tests to make this code solid enough prior to committing the changes necessary
to implement this enhancement.

#### Prerequisite testing updates

Since this is a new component for the Kubeflow ecosystem, testing infrastructure will be built from scratch, including unit tests for ETL pipeline, integration tests for backend services, and security validation.

#### Unit Tests
- `<package>`: `<date>` - `<test coverage>`

#### E2E tests
- E2E tests will be added to verify the complete RAG pipeline, from user query to response generation, including the UI interaction.

#### Integration tests
- Integration tests will be created to validate the interaction between the backend service, Milvus, KServe, and the GitHub API.

## Graduation Criteria

- **Alpha**: ETL pipeline processes website docs, basic RAG functionality working, local deployment completed.
- **Beta**: Multi-repository support, cloud deployment operational, community testing completed, performance targets met (< 5s response time).
- **Stable**: Full documentation coverage, production deployment, comprehensive testing, community adoption.

## Implementation History

- To be updated as development progresses

## Drawbacks

Potential Drawbacks Include:
- LLM may provide incorrect or outdated responses despite RAG implementation.
- Nightly ETL updates mean recent changes won't be immediately reflected.
- Responses confined to ingested sources; may miss broader context.
- Success depends on effective system prompts and guardrails to prevent misuse.
- Significant computational resources required for LLM inference.

## Alternatives

- **KubeGPT**: Existing Kubernetes-focused AI assistant for cluster analysis, but focused on operations rather than documentation assistance.
- **ChatGPT/Claude Integration**: Commercial LLM APIs could reduce infrastructure overhead but raise data privacy concerns and external service dependencies.
- **Kubernetes-Native GPT Solutions**: Solutions like K8sGPT and Robusta focus on operational aspects rather than comprehensive documentation assistance, making them complementary rather than competitive.
