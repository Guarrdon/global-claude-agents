---
description: Deployment workflow - deploy applications with safety checks and verification.
---

# Deployment Workflow

You are orchestrating a deployment. You will spawn deploy-engineer agents with proper safety checks.

## Your Task

$ARGUMENTS

## CRITICAL: Safety First

Before ANY deployment:
1. **Confirm target environment** - dev/staging/prod?
2. **For production** - Require explicit user confirmation
3. **Check rollback plan** - Can we undo if needed?

## Pre-Deployment Checklist

Run these checks before spawning deploy-engineer:

```bash
# Build passes
npm run build

# Type check passes (if TypeScript)
npm run typecheck

# Tests pass
npm test

# Correct cloud credentials configured
aws sts get-caller-identity  # or equivalent
```

## How to Spawn Deploy Engineer

```
Task(
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "deploy-engineer: deploy to <environment>",
  prompt: """
    You are a deployment engineer. Execute this deployment safely.

    ## Task
    <deployment task>

    ## Environment
    <dev/staging/prod>

    ## Project Context
    Read CLAUDE.md for:
    - Deployment target (AWS ECS, Vercel, etc.)
    - Deployment scripts location
    - Environment-specific configurations

    ## Deployment Steps
    1. Verify pre-deployment checklist passed
    2. Build deployment artifact (Docker image, etc.)
    3. Push to registry/platform
    4. Update service/trigger deployment
    5. Wait for stability
    6. Verify health checks pass

    ## Health Verification
    - Check health endpoints return 200
    - Verify application logs show startup success
    - Test basic functionality

    ## Rollback Plan
    <how to rollback if needed>

    ## NEVER Do
    - Deploy to production without explicit confirmation
    - Skip health verification
    - Proceed if pre-deployment checks failed
  """
)
```

## AWS ECS Deployment Pattern

For projects using AWS ECS (like StreamlineSales):

```bash
# 1. Build Docker image (linux/amd64 for ECS)
docker build --platform linux/amd64 -t <image-name> .

# 2. Push to ECR
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com
docker tag <image-name> <ecr-url>:<tag>
docker push <ecr-url>:<tag>

# 3. Update ECS service
aws ecs update-service --cluster <cluster> --service <service> --force-new-deployment

# 4. Wait for stability
aws ecs wait services-stable --cluster <cluster> --services <service>

# 5. Verify health
curl https://<url>/api/healthz
```

## Database Initialization (if needed)

After deploying to new environment:
```bash
curl -X POST https://<url>/api/admin/init-db
curl -X POST https://<url>/api/admin/seed-db  # dev/demo only
```

## Rollback Procedure

```bash
# ECS rollback (deploy previous task definition)
aws ecs update-service --cluster <cluster> --service <service> --task-definition <previous-task-def>

# Or redeploy previous Docker image
docker pull <ecr-url>:<previous-tag>
# ... push and update service
```

## Execution

1. Confirm target environment with user
2. For production: require explicit "yes, deploy to production"
3. Run pre-deployment checklist
4. Spawn deploy-engineer with full context
5. Monitor deployment progress
6. Verify health checks pass
7. Report success or initiate rollback
