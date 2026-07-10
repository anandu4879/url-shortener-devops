# Sprint 1 — Git & Repository Structure

## Objective

Create a professional repository structure and Git workflow.

---

## Topics Covered

- Git fundamentals
- Trunk-based development
- Conventional Commits
- Branch protection
- Repository structure
- .gitignore

---

## Repository Structure

Directory structure:
└── anandu4879-url-shortener-devops/
    ├── README.md
    ├── docker-compose.yml
    └── app/
        ├── Dockerfile
        ├── requirements.txt
        └── src/
            └── main.py


---

## Git Workflow

feature/*

↓

Pull Request

↓

Review

↓

Merge into main

---

## Decisions

### Why Trunk-Based Development?

- Simpler workflow
- Continuous Delivery friendly
- Industry standard

Alternative

Git Flow

---

## Conventional Commits

Examples

feat(app):

fix(terraform):

docs(readme):

ci(actions):

---

## Lessons Learned

- Good Git history is documentation .
- Infrastructure and application code should remain separated.
- Terraform state should never be committed.

---

---
