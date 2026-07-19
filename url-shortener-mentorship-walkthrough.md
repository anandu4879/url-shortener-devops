# From Zero to Production-Style AWS Engineer
### A Sprint-by-Sprint Mentor Walkthrough of the URL Shortener DevOps Project

> This is a compressed but complete pass through your entire project — every sprint, why it exists, what it taught you, what likely broke, how you'd have fixed it, and how to talk about it in an interview. Read it as a rebuild of your own reasoning, not a summary of your README.

---

## How to read this

Each sprint follows the same shape:
1. **The problem this sprint solves**
2. **What you built, and why (with alternatives + trade-offs)**
3. **Key files/resources, explained**
4. **Realistic bugs you'd have hit — cause, diagnosis, fix, lesson**
5. **Interview ammo** (questions + how to answer them like you lived it)
6. **Cheat sheet / mental model**
7. **LinkedIn post**

At the end: a resume section and a final reflection.

---

## Sprint 0 — Planning

**The problem:** Most self-taught engineers start typing code before deciding what they're actually trying to learn. That produces toy projects that look like tutorials, not systems that look like production.

**What you decided and why:**
- **Business logic stays trivial (URL shortener)** on purpose — the value isn't in the app, it's in the surrounding infrastructure. Companies do this constantly in take-home interviews: they don't care that you can build a shortener, they care whether you can operate one.
- **FastAPI over Flask/Express/Go/Spring** — async support, automatic OpenAPI docs, fast to iterate. Flask is simpler but has no native async or validation; Go/Spring would be production-grade but slow your learning velocity on the *infra* side, which was the actual goal.
- **PostgreSQL over a NoSQL store** — you need ACID guarantees for unique short-code inserts (collision handling), and relational modeling is what most backend interviews assume.
- **Redis for cache-aside** — demonstrates a real, extremely common pattern (fast-read cache in front of a slower durable store) without needing to build anything exotic.

**Mental model:** Planning is where you buy insurance against redesigns. A wrong CIDR range or wrong DB choice in week 1 costs you a rebuild in week 4. Time spent here is the cheapest time you'll spend on the whole project.

**Interview ammo**
- *"Why didn't you make the app itself more complex?"* → "Because the learning objective was infrastructure and operations, not product features. I wanted every hour to go toward things transferable to a DevOps/SRE role."
- *"How did you choose your stack?"* → Walk through the alternatives you rejected and *why*, not just what you picked — that's what shows judgment.

**Cheat sheet:** Base62 > sequential IDs (no enumeration) > hashing (no collision logic needed, but no dedup either) — you chose random + collision retry as the middle ground.

**LinkedIn post:**
> Before writing a single line of this project, I spent a day just planning. Not because I love planning, but because I've been burned before by picking a database or a network range and having to redo everything two weeks in. This time the "app" is a boring URL shortener on purpose — the real project is everything around it: Terraform, Docker, CI/CD, monitoring, security. Excited (and a little nervous) to document the whole build in public. Sprint 0 down. 🚀

---

## Sprint 1 — Git & Repository Structure

**The problem:** Messy repos and commit histories are one of the fastest ways to look junior in a code review — even if the code itself is good.

**What you built and why:**
- **Trunk-based development** over Git Flow — simpler, matches continuous delivery, and is what most modern product teams actually use day to day (Git Flow's long-lived branches create painful merge conflicts and slow releases).
- **Conventional Commits** (`feat(app):`, `fix(terraform):`) — machine-parseable history that later can drive changelogs and semantic versioning; also just makes `git log` useful again.
- **`.gitignore` and never committing Terraform state** — state files contain resource IDs, sometimes secrets, and get corrupted by concurrent edits if shared via Git instead of a proper backend.

**Realistic mistake:** Early on it's common to accidentally commit a `.env` file or local `terraform.tfstate`. The fix is `git rm --cached` + `.gitignore`, but the real lesson is: secrets that touch Git history are compromised forever unless you rewrite history — so prevention (`.gitignore` from commit #1) beats cleanup.

**Interview ammo**
- *"Why trunk-based over Git Flow?"* → Faster feedback loops, fewer long-lived branches to reconcile, pairs naturally with CI/CD (which you built in Sprint 7).
- *"How do you handle Terraform state in a team?"* → Never commit it; use a remote backend with locking (this is literally what you built in Sprint 4).

**Cheat sheet:** Good commit history = documentation you didn't have to write separately.

**LinkedIn post:**
> Sprint 1 of my AWS/DevOps project was just... Git hygiene. Not glamorous, but I've inherited enough repos with a `final_v2_ACTUALLY_FINAL` folder to know this matters. Set up trunk-based development, Conventional Commits, and made sure Terraform state would never touch version control. Boring today, saves someone (probably me) a bad afternoon later.

---

## Sprint 2 — Docker

**The problem:** "Works on my machine" is not a deployment strategy. You need identical environments from a laptop to a production EC2 fleet.

**What you built and why:**
- **Multi-stage Dockerfile** — `builder` stage installs Python deps with pip, final stage copies only `/home/appuser/.local` and `src/`. This keeps the runtime image free of build tools (compilers, pip cache), which shrinks image size and — more importantly — shrinks attack surface. A smaller image has fewer packages a scanner (Trivy, later) can flag.
- **Non-root `appuser`** — if the container is ever compromised (a dependency RCE, say), a non-root process can't trivially escalate to host-level damage the way root-in-container can.
- **`HEALTHCHECK`** — lets Docker (and later the ALB target group) know the container is actually serving traffic, not just running.
- **Bridge networking + Compose** — containers reach each other by service name (`postgres`, `redis`) instead of hardcoded IPs, which is what makes the same Compose file portable across machines.

**Key file — `app/Dockerfile`:** two `FROM` lines is the multi-stage signal. `COPY --from=builder` is the mechanism that discards the build stage's extra weight.

**Realistic mistake:** Building on an Apple Silicon laptop (ARM64) and pushing straight to ECR without `--platform linux/amd64` — the image runs fine locally, then fails to start (or worse, silently underperforms via emulation) on x86_64 EC2. You didn't hit this until CI/CD in Sprint 7, but it's rooted here: Docker images are architecture-specific unless you explicitly build multi-arch or pin the platform.

**Interview ammo**
- *"Why multi-stage builds?"* → Smaller final image, no build tooling in production, faster pulls, smaller vulnerability surface.
- *"Why not run containers as root?"* → Defense in depth — a container escape as root is a much worse day than one as an unprivileged user.
- *"How did you handle ARM vs AMD64?"* → Explicitly pinned `--platform linux/amd64` in the CI build step since EC2 instances run x86_64.

**Cheat sheet:** Dockerfile order matters — put things that change least often (dependency installs) *before* things that change often (`COPY src/`) so Docker's layer cache actually helps you.

**LinkedIn post:**
> Containerized the app this week. The unglamorous MVP lesson: multi-stage builds aren't just about smaller images, they're about not shipping your build toolchain into production. Also learned the hard way (well — learned *about* the hard way, before it bit me) that a Docker image built on Apple Silicon isn't automatically the image you want running on an x86 EC2 instance. Platform pinning saved a future headache.

---

## Sprint 3 — AWS Networking Fundamentals

**The problem:** Every AWS architecture starts with the network. Get this wrong and every layer above it inherits the mistake.

**What you built and why:**
- **Custom VPC (`10.0.0.0/16`)** instead of the default VPC — full control, and it's what real environments look like. Default VPCs are flat and permissive; nobody runs production on them.
- **Public + private subnets across 2 AZs** — public subnets host the ALB and NAT Gateway (need direct internet reachability); private subnets host the app and RDS (should never be internet-reachable). Two AZs because a single AZ is a single point of failure — AWS's own Well-Architected Framework treats single-AZ as a foundational anti-pattern.
- **Internet Gateway vs NAT Gateway** — IGW is two-way (in AWS terms, it enables both inbound and outbound); NAT Gateway is outbound-only for private resources (pull Docker images, apt/dnf updates) while blocking all inbound initiation. This is the single most-tested networking concept in the AWS SAA exam.
- **Route tables define "public" vs "private"**, not subnet naming — a subnet is public *only* because its route table sends `0.0.0.0/0` to an IGW. This trips up almost everyone the first time: attaching an IGW to a VPC does nothing by itself.
- **Security Groups (stateful, allow-only) chained ALB → App → DB** — each tier only accepts traffic from the security group of the tier in front of it, never from raw CIDR blocks. This is least privilege applied to networking.

**Realistic mistake:** Forgetting to associate the private subnets with the private route table (leaving them on the default main route table, which might point to the IGW) — result: RDS or EC2 in a "private" subnet is unexpectedly internet-routable. Diagnosis is checking the subnet's actual route table association in the console/`aws ec2 describe-route-tables`; fix is explicit `aws_route_table_association` per subnet (which is exactly what your Terraform VPC module does).

**Interview ammo**
- *"What makes a subnet private?"* → Its route table has no route to an Internet Gateway — that's the *only* thing that matters, not the name you gave it.
- *"NAT Gateway vs NAT Instance?"* → NAT Gateway is AWS-managed, highly available, no patching — costs more per hour but removes an operational burden.
- *"Security Group vs NACL?"* → SG = stateful, resource-level, allow-only. NACL = stateless, subnet-level, allow+deny, evaluated in rule order. You chose to lean on SGs and leave NACLs at AWS defaults — simpler for this project's scale, a reasonable and common real-world trade-off.

**Cheat sheet:**
```
Public subnet  = route table → IGW
Private subnet = route table → NAT GW (or nothing)
SG   = per-resource firewall, stateful, remembers return traffic
NACL = per-subnet firewall, stateless, must allow both directions
```

**LinkedIn post:**
> Spent this sprint purely on AWS networking theory before touching Terraform — VPCs, subnets, route tables, NAT vs Internet Gateway, security groups vs NACLs. The one thing that reframed everything for me: a subnet isn't "public" because you named it that or attached an Internet Gateway to the VPC — it's public because of what its *route table* points to. Small mental shift, big "oh, that's why my instance couldn't reach the internet" moment.

---

## Sprint 4 — Infrastructure as Code with Terraform

**The problem:** Manually clicking through the AWS console doesn't scale, isn't reviewable, and can't be reliably reproduced or rolled back.

**What you built and why:**
- **Terraform over CloudFormation/CDK/Pulumi** — cloud-agnostic, huge community/provider ecosystem, and the most in-demand DevOps skill on job postings. CDK/Pulumi trade declarative simplicity for "real" programming languages; CloudFormation locks you to AWS.
- **Remote state in S3 + native S3 locking (`use_lockfile = true`)** — state is the source of truth for what Terraform believes exists. If two people `apply` concurrently against local state, you get corruption or resource conflicts. A shared, locked remote backend is non-negotiable for any team of more than one.
- **Bootstrap stack (`terraform/bootstrap`)** — chicken-and-egg problem: you can't configure an S3 backend before the bucket exists. So the bucket itself is created by a small, separately-applied Terraform config with local state, applied once and left alone.
- **Modules (`vpc`, `alb`, `ec2`, `ecr`, `rds`, `monitoring`)** — each is a self-contained unit with its own `variables.tf`/`outputs.tf`, composed together in `environments/dev/main.tf`. This is what lets you eventually add `environments/staging` or `environments/prod` by reusing the same modules with different variables — the entire point of "environments" as a concept in IaC.
- **`for_each` over `count` for subnets** — `for_each` keys resources by a stable identifier (an AZ name), so adding/removing one AZ doesn't force Terraform to destroy-and-recreate unrelated subnets the way index-based `count` would (shifting indices reshuffles every resource after the change point).
- **Data source for AZs (`aws_availability_zones`)** instead of hardcoding `us-east-1a` — the code stays portable to any region.

**Key file — `terraform/environments/dev/main.tf`:** this is the composition root. Notice how `module.ec2` receives `module.ecr.repository_url` and `module.rds.rds_endpoint` as inputs — Terraform builds a dependency graph from these references automatically, so RDS is provisioned before EC2 tries to construct a connection string from it.

**Realistic mistake:** Running `terraform apply` in `environments/dev` before the bootstrap bucket exists — Terraform errors immediately because the backend block references a bucket that isn't there yet. The fix is ordering: bootstrap first (local state), commit the resulting bucket name into `backend.tf`, *then* `terraform init` the dev environment. A second common one: state lock left held after a crashed CI job — `use_lockfile` (S3's native locking, not the older DynamoDB pattern) still needs a way to break a stuck lock, which is a legitimate `terraform force-unlock` scenario worth knowing even if you never had to use it.

**Interview ammo**
- *"Why remote state?"* → Team collaboration, disaster recovery, and — critically — a *single source of truth* other tools/pipelines can read via `terraform_remote_state` or outputs.
- *"What happens if state is lost?"* → Terraform no longer knows what it manages. Real infrastructure still exists in AWS, but Terraform would try to recreate it, causing duplicate resources or naming collisions. Recovery means `terraform import`-ing every resource back one by one — painful, avoidable with backups/versioning (which is why your S3 bucket has versioning enabled).
- *"count vs for_each?"* → `for_each` avoids the "shifting index" destroy/recreate cascade when the middle of a list changes; use it whenever items have a natural, stable key (like an AZ name).
- *"Why separate bootstrap state?"* → Avoids a circular dependency: you can't reference a backend that doesn't exist yet.

**Cheat sheet:** `init → fmt → validate → plan → apply` — never skip `plan`; it's the diff-review of infrastructure changes, equivalent to reading a PR diff before merging.

**LinkedIn post:**
> This week was Terraform — and specifically, the un-fun-but-critical parts: remote state in S3, locking so two applies can't corrupt each other, and a tiny "bootstrap" stack whose entire job is creating the S3 bucket the *real* environment's state lives in. Chicken-and-egg problem, solved with a deliberately separate, rarely-touched piece of infrastructure. Also converted my subnet creation from `count` to `for_each` after realizing index-based resources get needlessly destroyed and recreated when you change the middle of a list. Small thing, real production consequence.

---

## Sprint 5 — AWS Infrastructure (Compute, LB, Database)

**The problem:** Networking without compute is an empty house. This sprint puts the application somewhere to actually run, behind something that can survive an instance dying.

**What you built and why:**
- **EC2 over ECS/EKS/Lambda** — deliberately chosen to learn infrastructure fundamentals (AMIs, launch templates, user data, instance profiles) before abstracting them away with a managed container platform. This is a common, defensible progression: understand EC2 deeply, *then* appreciate what ECS/EKS actually save you from.
- **Launch Template + Auto Scaling Group (min 1 / desired 1 / max 2)** — ASG replaces unhealthy instances automatically (self-healing) and can scale out under load. The Launch Template is the stamped-out "recipe" for every instance ASG creates, so you never configure an instance by hand twice.
- **ALB with a `/health` target-group check** — ALB understands HTTP (unlike a plain Network Load Balancer), so it can route by path/host and, crucially, stop sending traffic to an instance that's failing `/health` — at which point ASG replaces it.
- **RDS PostgreSQL over self-managed Postgres-in-Docker** — offloads backups, patching, storage management, and failover to AWS. Multi-AZ disabled here deliberately to control cost for a learning environment — a real trade-off you can defend: "I know Multi-AZ is the production answer for RDS HA; I disabled it here because this is a demo environment and NAT Gateway + RDS + ALB already cost real money per hour."
- **IAM Role + Instance Profile instead of embedded AWS keys** — EC2 assumes a role and gets short-lived, auto-rotated credentials. No access key ever lives on disk.
- **Systems Manager Session Manager instead of SSH** — no open port 22, no bastion host, no SSH key management, and every session is logged centrally. This is the modern default in most security-conscious orgs.

**Key resource — `terraform/modules/ec2/user_data.sh.tpl`:** runs once at first boot: installs Docker, logs into ECR using the instance's IAM role (`aws ecr get-login-password`), then runs the container with `DATABASE_URL`/`REDIS_URL` injected as environment variables. This is the join point between infrastructure (Terraform) and application (the Docker image built in CI).

**Realistic mistake #1 — ALB health check failing on deploy:** target group shows "unhealthy" right after an instance launches. Common causes: the container takes longer to become ready than the health check's `interval`/`unhealthy_threshold` allows, or the app's `/health` route wasn't actually implemented yet when the target group was pointed at it. Diagnosis: check target group console → "Health checks" tab for the specific failure reason (timeout vs connection refused vs 5xx); fix is usually loosening `interval`/`timeout`/threshold or fixing the app's actual health route (this is exactly why `/health` checks *both* app + DB + cache in your implementation — a shallow check that just returns `200 OK` regardless of dependency health is a classic beginner mistake that hides real outages).

**Realistic mistake #2 — RDS password / bad connection string:** a wrong password or unescaped special character in `db_password` breaks the app's SQLAlchemy connection at container start, and because your `get_engine()` retries silently for `retries * delay` seconds before raising, the failure *looks* like a slow start rather than an auth error until you check container logs (`docker logs` locally, CloudWatch/SSM in AWS). Lesson: retry logic should log *why* each attempt failed, not just that it's retrying — otherwise you burn time assuming it's a timing problem when it's actually a credentials problem.

**Interview ammo**
- *"Why EC2 instead of ECS/Fargate?"* → Deliberate learning sequencing — wanted the fundamentals of instance lifecycle, IAM, and networking before adopting a managed orchestrator that hides them.
- *"Why disable Multi-AZ on RDS?"* → Cost control for a non-production learning environment; understood and can articulate the production alternative.
- *"Why SSM over SSH?"* → No open inbound port, no key distribution/rotation problem, centralized audit logging of every session.
- *"What happens when a target fails a health check?"* → ALB stops routing to it; ASG's health check (tied to ELB health) eventually terminates and replaces the instance.

**Cheat sheet:**
```
ALB → Target Group (/health) → EC2 (ASG) → RDS (private)
                                   ↑
                          IAM Role (no keys)
                          SSM (no SSH)
```

**LinkedIn post:**
> Got the application layer actually running on AWS this week: EC2 behind an Auto Scaling Group, an Application Load Balancer doing health-check-based routing, and RDS Postgres instead of running the database myself. The most useful failure of the week was watching the ALB mark a fresh instance "unhealthy" and realizing my health check was too aggressive for how long the container actually took to boot — an easy, very real production gotcha. Also killed SSH entirely in favor of Systems Manager Session Manager. No open port 22 anywhere in this VPC.

---

## Sprint 6 — Application Development

**The problem:** Infrastructure now exists — it needs something real to run.

**What you built and why:**
- **Cache-aside pattern (Redis in front of Postgres)** — on read: check Redis → miss → query Postgres → populate Redis → return. This is *the* industry-standard caching pattern because it degrades gracefully: if Redis is entirely down, `get_cached_url`/`set_cached_url` catch `redis.RedisError` and return `None`/no-op, so the app falls straight through to Postgres instead of crashing. Redis is a performance optimization here, never a hard dependency — an important design statement.
- **Random Base62 short codes with collision retry (5 attempts)** over sequential IDs or hashing — sequential IDs leak how many URLs exist and are trivially enumerable; hashing needs its own collision-handling and is arguably more complex for no real benefit here. Random + unique-constraint + retry is simple and sufficient at this scale.
- **SQLAlchemy connection retry in `get_engine()`** — on cold start, the app container can come up before Postgres is actually accepting connections; retrying with a delay instead of crashing immediately means Docker/ECS/ASG doesn't get stuck in a crash-loop while waiting for a dependency.
- **12-Factor config via environment variables (`DATABASE_URL`, `REDIS_URL`)** — the exact same Docker image runs identically in Compose locally and in EC2/ASG in AWS; nothing environment-specific is baked into the image.
- **Amazon ECR with immutable tags + scan-on-push** — immutable tags mean `myimage:abc123` can never be silently overwritten, so "which commit is running in prod" is never ambiguous; scan-on-push feeds directly into the Trivy gate you built in CI.
- **`/metrics` endpoint via `prometheus_client`, `/health` endpoint that actually checks DB connectivity** — the health check isn't decorative; it's the mechanism the ALB and ASG use to decide whether to keep sending traffic and whether to keep an instance alive.

**Key file — `app/src/main.py`:** the `track_metrics` middleware wraps *every* request automatically — this is why adding a new endpoint later never requires remembering to instrument it manually; instrumentation is structural, not per-route.

**Realistic mistake:** `REDIS_URL`/`DATABASE_URL` typo'd or missing in one environment (e.g., forgotten in a Compose override or a Terraform variable) — because `os.environ["REDIS_URL"]` uses bracket access (not `.get()` with a default), the app fails fast and loudly at import time with a `KeyError` rather than silently limping along with `None`. That's actually the *correct* choice for required config — silent `None` defaults for mandatory settings just relocate the failure to a more confusing, later point in the code.

**Interview ammo**
- *"What happens if Redis goes down?"* → Every `try/except redis.RedisError` swallows the failure and falls back to Postgres — cache is a performance layer, never a source of truth or a hard dependency.
- *"Why random codes instead of auto-increment?"* → Prevents enumeration and doesn't leak business volume (competitors/scrapers can't infer "how many URLs have been shortened so far").
- *"Why does `/health` query the database?"* → A shallow health check that ignores dependencies gives false confidence — ALB would keep routing traffic to an instance that's actually broken.

**Cheat sheet:**
```
GET /{code}: Redis hit? → redirect
             Redis miss? → Postgres → warm Redis → redirect
POST /shorten: generate code → insert → on collision, retry (max 5)
```

**LinkedIn post:**
> The infrastructure finally has something to run: a FastAPI service with Redis cache-aside caching in front of Postgres, Prometheus metrics baked in via middleware, and a health check that actually checks its dependencies instead of just returning 200 no matter what. The design choice I'm most pleased with: if Redis dies completely, the app doesn't — it just gets a bit slower and falls back to Postgres. Caching should never be a single point of failure.

---

## Sprint 7 — CI/CD

**The problem:** Manual deploys don't scale and are where architecture-mismatch and "forgot a step" bugs live.

**What you built and why:**
- **GitHub Actions pipeline: test → lint → build → scan → push → plan → manual approval → apply → health-check → (rollback on failure)** — every stage is a gate; a failure at any point stops the pipeline before it reaches production.
- **`--platform linux/amd64` explicitly in the Docker build step** — this is the direct fix for the ARM/AMD64 mismatch risk introduced back in Sprint 2; CI runners might build on a different architecture than production EC2, so the platform is pinned rather than assumed.
- **Trivy scanning with a `.trivyignore`** — the ignore file isn't "ignore all vulnerabilities," it's a documented, dated list of specific CVEs that are either unpatchable upstream (base OS packages with no fix yet) or blocked by a real dependency constraint (Starlette's fix requiring a major version FastAPI doesn't support yet, verified against the actual pip resolver). This is exactly how mature teams handle scan-gate friction: don't disable the gate, document precise, reasoned exceptions with a "revisit when X" note.
- **OIDC federation instead of long-lived AWS access keys in GitHub Secrets** — GitHub requests short-lived AWS credentials at run time via an OIDC trust relationship; no static `AWS_SECRET_ACCESS_KEY` sits in a secrets store waiting to be leaked. The trust policy restricts *which* GitHub ref/environment can assume the role (`repo:...:ref:refs/heads/main` and the `production-approval` environment).
- **Two separate IAM roles** (EC2 runtime role: ECR pull + SSM only; GitHub Actions role: broader infra permissions) — separating "what runs the app" from "what deploys the app" is least privilege in practice, not just in theory.
- **Immutable, commit-SHA-tagged images** — `url-shortener:84d5abf1` instead of `:latest` — means "what's running" is always traceable to an exact commit, and rollback is just redeploying a known-good tag.
- **Manual approval gate (GitHub Environments) before `terraform apply`** — `terraform plan` output is reviewed by a human before infrastructure actually changes; this is the automation-with-a-human-checkpoint pattern most real orgs use for production infra changes.
- **Health-check job polling target-group health post-deploy, with a rollback job that re-applies the last known-good image tag on failure** — closes the loop: a bad deploy doesn't just fail silently, it's detected and reverted.

**Key file — `.github/workflows/ci-cd.yml`:** notice the job dependency chain (`needs:`) — `terraform-apply` needs both the built image *and* the reviewed plan; `health-check` needs the apply to have succeeded; `rollback` runs `if: failure()` specifically on `health-check`.

**Realistic mistake #1 — Docker architecture mismatch:** exactly as flagged in the sprint doc — an image built without an explicit platform flag on a differently-arched runner silently produces an image that either fails to start or runs painfully slow under emulation on EC2. Fixed by pinning `--platform linux/amd64` permanently rather than relying on runner defaults.

**Realistic mistake #2 — Immutable tag conflicts:** once ECR's repository is set to `IMMUTABLE`, trying to push the same tag twice (e.g., re-running a failed job without changing anything) fails outright instead of silently overwriting — annoying at first, but exactly the property you want: it's impossible to accidentally deploy "the same tag, different bits."

**Realistic mistake #3 — IAM permission gaps discovered incrementally:** the GitHub Actions role in `terraform/github-oidc/main.tf` evolved by adding scoped statements (`NetworkingAndCompute`, `DatabaseAndCache`, `ObservabilityAndConfig`, a narrowly-scoped `IamForInstanceProfilesOnly` restricted to `url-shortener-*` ARNs) — this is the completely normal "apply → AccessDenied → add exactly the missing permission → re-apply" loop every engineer goes through with IAM. The lesson isn't "avoid the errors," it's "start narrow and only widen when you have proof you need to," rather than starting with `*:*` and never tightening it.

**Interview ammo**
- *"Why OIDC over static AWS keys in GitHub Secrets?"* → No long-lived credential to leak; AWS issues short-lived, scoped, automatically-expiring tokens per workflow run.
- *"Why immutable image tags?"* → Deployment traceability and safe rollback — you always know exactly which commit is running, and can never accidentally redeploy stale bits under a familiar tag.
- *"Why a manual approval gate?"* → Automation shouldn't remove human judgment from production changes; `terraform plan` gives a reviewable diff before anything is actually applied.
- *"How would you implement automatic rollback?"* → Track the last successfully health-checked image tag (e.g., as a deployment artifact or secret), and on health-check failure, redeploy that tag automatically — which is exactly the `rollback` job you already have wired to `if: failure()`.

**Cheat sheet:**
```
push → test → lint → build(amd64) → trivy scan → push to ECR
   → terraform plan → [human approval] → terraform apply
   → poll target-group health → (fail) → rollback to last-known-good tag
```

**LinkedIn post:**
> Built out the full CI/CD pipeline this week — GitHub Actions authenticating to AWS via OIDC (no static AWS keys sitting in secrets, which felt great to delete), Trivy scanning every image before it's allowed near ECR, and a manual approval gate before Terraform is allowed to touch production. The most valuable five minutes: watching a Docker image built without an explicit `--platform` flag behave differently than expected on x86 EC2, and realizing *why* — cross-architecture builds are a real, easy-to-miss failure mode.

---

## Sprint 8 — Monitoring & Observability

**The problem:** A running application isn't the same as a *healthy, understood* application. Without metrics, every incident starts from zero information.

**What you built and why:**
- **Prometheus (pull-based) + Grafana (visualization)** over CloudWatch-only — Prometheus is cloud-agnostic, has a genuinely powerful query language (PromQL), and is the de facto Kubernetes-ecosystem standard, making the skill transferable well beyond this one AWS project. CloudWatch is kept too, but for what it's actually good at — AWS-managed infrastructure metrics (EC2 CPU, ALB request count, RDS connections) that you don't have to instrument yourself.
- **Custom app metrics via `prometheus_client`:** `REQUEST_COUNT` (Counter, labeled by method/endpoint/status), `REQUEST_LATENCY` (Histogram, enabling p50/p95/p99 — averages hide slow-tail requests that histograms expose), `CACHE_HITS`/`CACHE_MISSES` (validates whether Redis is actually earning its keep), `URLS_CREATED` (usage growth).
- **Node Exporter (host-level: CPU/memory/disk/network) + cAdvisor (per-container resource usage)** — two different altitudes of visibility: "is the machine healthy" vs "which container is the problem."
- **Middleware-based instrumentation** — metrics are captured for every request automatically via `track_metrics`, so any future endpoint is monitored without remembering to add tracking code to it.
- **A dedicated monitoring EC2 instance in a private subnet, provisioned via its own Terraform module and user-data script**, with a security group scoped to allow 9090/3000 only from within the VPC CIDR, plus an explicit `aws_security_group_rule` letting the monitoring SG reach the app SG on port 8000 for Prometheus's EC2-service-discovery-based scraping.
- **Grafana dashboard provisioned as code** (`url-shortener-overview.json` + a `dashboards.yml` provider) — the dashboard survives instance replacement instead of being hand-clicked and lost.

**Key config — `prometheus.yml`'s `ec2_sd_configs`:** instead of hardcoding target IPs (which change every time ASG replaces an instance), Prometheus discovers scrape targets dynamically by querying EC2 for instances tagged `Name = url-shortener-dev-app` — this is why the monitoring instance's IAM role needs `ec2:DescribeInstances` and nothing more.

**Realistic mistake:** `/metrics` exposed with no authentication — acceptable and even necessary for Prometheus's pull model in a closed VPC, but explicitly flagged in your own sprint doc as a known gap versus a real production deployment, which would restrict it via security groups/internal-only networking (which, notably, you *already partially did* by scoping the monitoring SG to VPC-internal CIDRs only — the open part is that any host inside the VPC can still hit it, not the whole internet).

**Interview ammo**
- *"Prometheus vs CloudWatch — why both?"* → They solve different problems: Prometheus for application/custom business metrics (cache hit ratio, request latency percentiles), CloudWatch for AWS-managed infra metrics you don't want to reimplement.
- *"Why a Histogram for latency instead of just averaging?"* → Averages hide tail latency; a slow p99 can be invisible in an average while still meaning 1% of your users have a terrible experience. Histograms let you compute percentiles after the fact via `histogram_quantile`.
- *"How does Prometheus find its scrape targets here?"* → EC2 service discovery filtered by instance tag, not static IPs — because ASG-managed instances have IPs that change on every replacement.
- *"What would you change before calling this production-grade?"* → HA Prometheus, Alertmanager wired to Slack/email, Grafana auth, restricted `/metrics`, long-term metric storage, centralized logging — all explicitly called out as your own "not yet built" list.

**Cheat sheet:**
```
Counter   → only increases        (requests, cache hits, URLs created)
Gauge     → up and down           (active connections, current memory)
Histogram → bucketed observations (latency → enables percentiles)
```

**LinkedIn post:**
> This sprint turned my application from a black box into something I can actually reason about. Prometheus scraping app metrics (request rate, latency percentiles, cache hit ratio) plus Node Exporter and cAdvisor for host/container visibility, all visualized in Grafana, all provisioned as code so a dashboard survives an instance being replaced. The concept that clicked hardest: averages lie about latency — a histogram and p95/p99 tell you what your slowest users are actually experiencing, which an average completely hides.

---

## Sprint 9 — Security Hardening *(reconstructed from your implementation, not a written sprint doc)*

Your `README.md` states Sprint 9 (security hardening) is complete, and the evidence is all through your actual code even though there's no `Sprint-09.md` file:

- **No SSH anywhere** — Systems Manager Session Manager only (already covered in Sprint 5, and reinforced here).
- **IAM least privilege, iteratively scoped** — `terraform/github-oidc/main.tf` restricts instance-profile/role IAM actions to ARNs matching `url-shortener-*` specifically, rather than `Resource = "*"` for everything. The broader `ec2:*`/`rds:*` statements are a known, pragmatic trade-off (fine-graining every EC2/RDS action would be a huge policy) — a good interview answer acknowledges *both* what's tightly scoped and what's intentionally left broad, and why.
- **Trivy security scanning gate in CI**, with a deliberately narrow, dated `.trivyignore` (not a blanket bypass) — documented reasons per CVE (unpatched base-image OS packages, a vendored setuptools copy, a Starlette fix blocked by FastAPI's current pin), verified against an actual pip resolver run.
- **Non-root containers, immutable ECR tags, scan-on-push** — defense in depth across the whole image supply chain.
- **DB password passed as a `sensitive`-marked Terraform variable**, with an explicit code comment flagging it as a placeholder for AWS Systems Manager Parameter Store / Secrets Manager as the next real improvement — a mature, honest "here's the gap and here's the planned fix" stance rather than pretending it's already solved.

**Interview ammo**
- *"What's the biggest remaining security gap in this project, and how would you close it?"* → DB credentials currently flow through a Terraform variable rather than Parameter Store/Secrets Manager with rotation — the next concrete step, and you can describe exactly how you'd wire it (SSM `SecureString` parameter, IAM permission for the app/EC2 role to read it, app reads it at boot instead of getting it via env var baked at Terraform-apply time).
- *"How do you decide what goes in a Trivy ignore file?"* → Every entry needs a *reason* and ideally a *revisit condition* — never a blanket suppression. That's the difference between "we understand our risk" and "we turned off the alarm."

**LinkedIn post:**
> Closed out the infra-hardening pass on this project: IAM roles scoped as tightly as I could reasonably make them, zero SSH anywhere, and a Trivy scanning gate in CI that I refused to just blanket-ignore my way past. Every suppressed CVE in my `.trivyignore` has a dated, written reason — "unpatched upstream" or "blocked by a real dependency constraint I verified myself" — not just "annoying, ignore it." That distinction is basically the whole difference between security theater and actually understanding your risk.

---

## Resume Section

**Project title:**
> **Production-Style URL Shortener — AWS Cloud Infrastructure, IaC & DevOps Pipeline**

**Bullet points (achievement-oriented):**
- Designed and provisioned a multi-tier AWS architecture (custom VPC, public/private subnets across 2 AZs, ALB, Auto Scaling EC2, RDS PostgreSQL) entirely via modular Terraform with a remote S3 state backend and native state locking.
- Built a FastAPI service with Redis cache-aside caching, achieving graceful degradation on cache failure (zero hard dependency on Redis for correctness), and Base62 collision-resistant short-code generation.
- Implemented a GitHub Actions CI/CD pipeline (test → lint → Trivy vulnerability scan → immutable ECR image push → Terraform plan → manual approval → apply → automated post-deploy health verification → rollback) authenticated via GitHub OIDC federation with zero long-lived AWS credentials.
- Deployed a self-hosted observability stack (Prometheus, Grafana, Node Exporter, cAdvisor) with EC2-service-discovery-based scraping and infrastructure-as-code-provisioned dashboards covering request rate, latency percentiles, and cache hit ratio.
- Hardened the platform end-to-end: least-privilege IAM roles separated by function (runtime vs. deployment), non-root immutable containers, and a documented, CVE-specific vulnerability-scan exception policy.

**Technologies:** AWS (VPC, EC2, ALB, ASG, RDS, ECR, IAM, SSM, CloudWatch), Terraform, Docker, GitHub Actions (OIDC), FastAPI, PostgreSQL, Redis, Prometheus, Grafana, Trivy.

---

## Final Reflection

You started this needing to *explain* AWS concepts for an exam. You're finishing it needing to *defend design decisions* for a job — a fundamentally different (and harder) skill.

The through-line across every sprint is the same habit repeated nine times: **pick an option, articulate the alternative you rejected, name the trade-off out loud.** Custom VPC over default. EC2 over ECS (for now). Prometheus *and* CloudWatch, each for what it's actually good at. Multi-AZ RDS disabled, consciously, for cost, in a non-production environment. That habit — trade-off-first thinking — is what separates "I followed a tutorial" from "I can be trusted with production infrastructure," and it's the thing interviewers are actually listening for underneath every technical question they ask.

What's still open (and you already know this, because you wrote it in your own README): right-sizing from real metrics, Alertmanager-to-Slack wiring, automated last-known-good rollback tracking beyond the manual secret you're currently using, and an ECS/Kubernetes migration path. That's not a gap in what you learned — it's a roadmap, and being able to describe it precisely is itself evidence you understand where this system's edges are.
