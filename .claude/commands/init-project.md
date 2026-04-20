---
description: Initialize local development environment
argument-hint: ""
---

# Initialize Project

Set up and start the project locally based on the detected project type.

## Step 1: Detect Project Type

Read the project root to identify the stack:

```bash
ls -la
```

| Config file found | Project type |
|-------------------|-------------|
| `pyproject.toml` or `requirements.txt` | Python |
| `pom.xml` | Java / Maven |
| `build.gradle` | Java / Gradle |
| `package.json` | Node.js / TypeScript |
| Other | Check README for setup instructions |

Also read `CLAUDE.md` → **Commands** section for project-specific setup commands, which take priority over the defaults below.

---

## Step 2: Set Up Environment File

```bash
cp .env.example .env
```

If `.env.example` does not exist, check README or CLAUDE.md for required environment variables.

---

## Step 3: Install Dependencies

**Python (uv):**
```bash
uv sync
```

**Python (pip):**
```bash
pip install -r requirements.txt
```

**Java (Maven):**
```bash
mvn install -DskipTests
```

**Java (Gradle):**
```bash
./gradlew build -x test
```

**Node.js / TypeScript:**
```bash
npm install
# or: yarn install / pnpm install
```

---

## Step 4: Start Required Services

If the project uses Docker for databases or other services:

- **Before starting**, ask user: `"Starting Docker services and potentially running database migrations. Proceed? (yes/no)"`
- Confirm which services are defined in `docker-compose.yml` before running.

```bash
docker-compose up -d
```

---

## Step 5: Run Database Migrations (if applicable)

- **Before running migrations**, confirm with the user if this is a production or staging environment (migrations are typically irreversible).

**Python / Alembic:**
```bash
uv run alembic upgrade head
```

**Java / Flyway or Liquibase:**
Migrations typically run automatically on startup.

**Node.js / Prisma:**
```bash
npx prisma migrate deploy
```

---

## Step 6: Start Development Server

Use the command from `CLAUDE.md` → Commands section. Common defaults:

**Python / FastAPI:**
```bash
uv run uvicorn app.main:app --reload
```

**Java / Spring Boot:**
```bash
mvn spring-boot:run
```

**Node.js:**
```bash
npm run dev
```

---

## Step 7: Validate Setup

Check that the application is running:

- Read CLAUDE.md for the health check URL or test command
- Run the project's smoke test if available
- Confirm no errors in startup logs

---

## Confirmation

After setup, report:
- Project type detected
- Services started
- Server URL and port
- Any warnings or manual steps required

**Next step**: Run `/prime` to load full project context into a new session.

**If any step fails**: Check the project README or CLAUDE.md for alternative instructions and report the error details to the user.

