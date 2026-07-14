# Extended Tutorials Collection — 15 Detailed Scenarios

This document provides **15 comprehensive, ready-to-use tutorials** for Agent Zero + Ollama.

Each tutorial includes:
- Clear **Goal**
- **Detailed Sample Prompt** (copy-paste ready)
- **Step-by-Step Guiding Recipe** — exact phrases and sequence to use when chatting with the agent
- **Pro Tips, Variations & Expected Outcome**

These recipes are optimized for Agent Zero’s agentic capabilities (code generation, file creation, terminal execution, iteration, and tool use).

---

## Tutorial 1: Build a Beautiful Pomodoro Timer (Web App)

**Goal:** Create a modern, self-contained productivity web app.

**Detailed Sample Prompt:**
> Create a premium, responsive single-file Pomodoro timer using Tailwind CSS 3.4+ and vanilla JavaScript. Include: beautiful circular SVG progress indicator with smooth animation, three modes (Work 25min, Short Break 5min, Long Break 15min) with auto-switching and session counter, Web Audio API for pleasant notification sounds, keyboard shortcuts (Space = start/pause, R = reset, numbers for mode switching), dark/light theme with localStorage persistence, statistics panel (completed sessions today, total focus time), and a clean, modern, professional UI suitable for a productivity SaaS. Make it fully functional and beautiful.

**Step-by-Step Guiding Recipe:**

1. Paste the sample prompt above.
2. When the agent returns the HTML code:  
   **Reply:** "Perfect. Save this as `pomodoro-timer/index.html`. Create the folder structure if needed."
3. **Next:** "Now test it by opening the file in a browser (or serve it). Tell me if there are any issues."
4. **Iteration:** "Add a settings modal where the user can customize work/break durations and notification sound volume."
5. **Polish:** "Add confetti animation on completing a work session using canvas-confetti. Make the UI even more premium with subtle glassmorphism effects."
6. **Final:** "Generate a README.md explaining how to use it, keyboard shortcuts, and how to self-host it."

**Pro Tips & Variations:**
- Ask for PWA support (manifest + service worker).
- Add task integration: "When a pomodoro finishes, prompt the user to log what they worked on."
- Expected Outcome: A beautiful, fully working `index.html` you can open directly or host on GitHub Pages/Netlify.

---

## Tutorial 2: Feature-Rich Todo App with Persistence & Drag-and-Drop

**Goal:** Build a production-quality todo application.

**Detailed Sample Prompt:**
> Build a clean, modern, responsive Todo application in a single HTML file using Tailwind CSS. Features must include: add/edit/delete tasks, priority levels (Low/Medium/High) with color coding, due dates with overdue highlighting, search + filter by status/priority, drag-and-drop reordering (using SortableJS or native HTML5), subtasks, tags, localStorage persistence, dark mode, export to JSON/CSV, and beautiful micro-animations. Make the UX delightful.

**Step-by-Step Guiding Recipe:**

1. Paste the prompt.
2. **Reply after code:** "Save as `todo-app/index.html`. Create `todo-app/` folder."
3. **Test:** "Open it and create 5 sample tasks with different priorities and due dates. Show me screenshots or describe the result."
4. **Enhance:** "Add a 'Focus Mode' that hides completed tasks and shows only today's due items."
5. **Advanced:** "Implement recurring tasks (daily/weekly) and a simple calendar view using fullcalendar or simple grid."
6. **Package:** "Create a README.md and make it installable as a PWA."

**Pro Tips:**
- Use the agent to debug drag-and-drop issues by pasting console errors.
- Expected Outcome: A complete, delightful todo app ready to use offline.

---

## Tutorial 3: Python Data Analysis & Visualization Script

**Goal:** Professional EDA pipeline with beautiful outputs.

**Detailed Sample Prompt:**
> Write a complete, well-commented Python 3.11+ script that performs full Exploratory Data Analysis on a CSV file. Use pandas, matplotlib, seaborn, and plotly (interactive). Features: automatic data profiling, missing value analysis + imputation suggestions, correlation heatmap (interactive), distribution plots for numeric columns, categorical analysis, outlier detection, and generation of a beautiful HTML report using ydata-profiling or sweetviz + custom sections. Include example usage, a sample synthetic CSV in comments, and save all charts + report to an `output/` folder. Make it production-ready with logging and CLI arguments (argparse or typer).

**Step-by-Step Guiding Recipe:**

1. Paste prompt.
2. **Reply:** "Save the script as `data-analysis/analyze.py` and create `data-analysis/output/`."
3. **Test:** "Generate a small synthetic dataset (20 rows) and run the script. Show me the output folder contents and key insights from the report."
4. **Improve:** "Add support for multiple CSV files and a comparison mode between two datasets."
5. **Visual Polish:** "Make all plots publication-quality with consistent styling and add an executive summary section at the top of the HTML report."
6. **Deploy:** "Create a Streamlit version of the dashboard as an alternative interface."

**Pro Tips:**
- Ask the agent to run the script inside its environment and fix any library issues.
- Expected Outcome: A reusable `analyze.py` + beautiful HTML report.

---

## Tutorial 4: Smart File Organizer Automation Script

**Goal:** Intelligent, safe file organization tool.

**Detailed Sample Prompt:**
> Create a robust Python CLI tool that intelligently organizes a target folder (default: ~/Downloads). Features: sort by file type + creation date into structured folders (Images/2025-07/, Documents/, Code/, Videos/, Archives/), duplicate detection using file hash, safe mode with --dry-run, detailed logging, undo capability (by generating a revert script), ignore list via .organizerignore, and a beautiful rich terminal UI using rich or textual. Include comprehensive error handling and progress bars.

**Step-by-Step Guiding Recipe:**

1. Paste prompt.
2. **Reply:** "Save as `file-organizer/organize.py`. Make it executable."
3. **Test safely:** "Run it with --dry-run on a test folder with mixed files. Show me the planned actions."
4. **Real run:** "Now run it for real on a small test folder and show the before/after structure."
5. **Enhance:** "Add AI-powered categorization using filename + content analysis (simple rules or integrate with local LLM if possible)."
6. **Package:** "Create setup.py / pyproject.toml, README with examples, and a dockerized version."

**Pro Tips:**
- Use `--dry-run` extensively in early iterations.
- Expected Outcome: A trustworthy automation tool you can run daily.

---

## Tutorial 5: Production-Ready FastAPI CRUD + Docker

**Goal:** Full backend API with best practices.

**Detailed Sample Prompt:**
> Generate a complete, production-ready FastAPI project for a "Tasks" resource. Include: Pydantic v2 models with validation, SQLite + SQLAlchemy 2.0 + Alembic migrations, JWT authentication (fake users for demo), CRUD endpoints with proper status codes and error handling, pagination + filtering, OpenAPI docs customization, health check endpoint, structured logging, and Docker support. Provide: multi-stage Dockerfile (non-root user), docker-compose.yml with healthchecks, .env.example, and a simple HTML frontend that consumes the API. Make it clean and well-documented.

**Step-by-Step Guiding Recipe:**

1. Paste prompt.
2. **Reply:** "Create the full project structure under `fastapi-tasks/` with all files."
3. **Test:** "Build and run with docker compose up. Test the API with curl or the HTML frontend. Show endpoints working."
4. **Secure:** "Add rate limiting and input sanitization."
5. **Enhance:** "Add user roles (admin/user) and task assignment."
6. **CI/CD:** "Generate a GitHub Actions workflow for testing + building the image."

**Pro Tips:**
- Ask the agent to fix any import or migration issues by running commands.
- Expected Outcome: A complete, deployable FastAPI project.

---

## Tutorial 6: Personal Second Brain / Knowledge Base System

**Goal:** Markdown-based PKM with smart tools.

**Detailed Sample Prompt:**
> Design and implement a complete personal knowledge management (second brain) system using Markdown files. Create: recommended folder structure (Projects/, Areas/, Resources/, Archives/, Daily/), beautiful note templates (with YAML frontmatter), a powerful Python CLI tool that can search (using ripgrep or whoosh), link notes, generate daily/weekly review summaries, find orphaned notes, suggest connections using simple embeddings or keyword overlap, and export to Obsidian-compatible format. Include a simple web viewer (using MkDocs or a custom Flask/FastAPI app).

**Step-by-Step Guiding Recipe:**

1. Paste prompt.
2. **Reply:** "Create the full structure under `second-brain/` including templates, CLI tool (`brain.py`), and web viewer."
3. **Populate:** "Create 5 example notes in different folders using the templates."
4. **Test CLI:** "Run searches, generate a weekly review, and show connection suggestions."
5. **Enhance:** "Add automatic backlink generation and a graph visualization using vis.js or similar."
6. **Polish:** "Make the web viewer beautiful with Tailwind and add full-text search."

**Pro Tips:**
- This works great with local models for semantic search later.
- Expected Outcome: A fully functional second brain you can start using immediately.

---

## Tutorial 7: Interactive Text Adventure Game

**Goal:** Engaging, replayable adventure game.

**Detailed Sample Prompt:**
> Create an immersive text-based adventure game in Python with rich library for beautiful terminal output. Features: 8+ interconnected locations, inventory system, multiple NPCs with dialogue trees, 3+ puzzles, combat or skill challenges, at least 4 different endings, save/load system, and a hint system. Make the world coherent and story-driven. Provide a map and walkthrough in the README.

**Step-by-Step Guiding Recipe:**

1. Paste prompt.
2. **Reply:** "Save the game as `text-adventure/game.py` and create supporting files."
3. **Playtest:** "Start the game and play through one full path. Report any bugs or boring sections."
4. **Improve:** "Add more descriptive text, sound effects (using playsound or just ASCII), and a journal that tracks discoveries."
5. **Expand:** "Add a second major area and 2 new endings."
6. **Package:** "Create a web version using Flask + simple HTML interface + save via localStorage."

**Pro Tips:**
- Great for testing the agent’s long-context and planning abilities.
- Expected Outcome: A fun, complete game you can play in terminal or browser.

---

## Tutorial 8: Complete DevOps Starter Kit (Docker + GitHub Actions + Deploy)

**Goal:** Production DevOps template for any Python project.

**Detailed Sample Prompt:**
> For a Python web project (FastAPI or Flask), generate a complete production DevOps setup: multi-stage Dockerfile with non-root user and security best practices, docker-compose.yml with healthchecks, environment separation (dev/prod), GitHub Actions CI/CD workflow that runs linting, tests, builds image, and deploys to a VPS via SSH + docker compose, monitoring with Prometheus + Grafana (basic), and a Makefile with common commands. Include secrets management guidance and rollback strategy.

**Step-by-Step Guiding Recipe:**

1. Paste prompt.
2. **Reply:** "Create `devops-kit/` with Dockerfile, docker-compose files, .github/workflows/deploy.yml, Makefile, and docs."
3. **Validate:** "Run the CI workflow locally using act or explain how to test it."
4. **Harden:** "Add Trivy vulnerability scanning and SBOM generation to the pipeline."
5. **Deploy simulation:** "Show the commands needed to deploy to a fresh VPS."
6. **Document:** "Write a complete `DEPLOYMENT.md` guide."

**Pro Tips:**
- Ask the agent to make the workflow use OIDC for better security.
- Expected Outcome: Copy-paste ready DevOps foundation for your projects.

---

## Tutorial 9: AI Research Agent + Personalized 30-Day Learning Roadmap

**Goal:** Deep research + actionable personal plan.

**Detailed Sample Prompt:**
> Act as a senior AI researcher. Provide a comprehensive, up-to-date (2026) overview of the best open-source local LLM agent frameworks, tools, and techniques. Compare Agent Zero with alternatives. Then create a **personalized 30-day learning roadmap** for me to become highly proficient with Agent Zero + Ollama. Include: weekly themes, specific projects to build each week, recommended models, key papers/resources, daily/weekly habits, and milestones with success criteria.

**Step-by-Step Guiding Recipe:**

1. Paste the prompt.
2. **Deep dive:** "Expand on the top 3 most promising techniques for 2026 and give concrete examples."
3. **Customize:** "Make the roadmap more aggressive (21 days) or more beginner-friendly depending on my level. Assume I have intermediate Python knowledge."
4. **Add resources:** "For each week, add the best free YouTube videos, GitHub repos, and papers."
5. **Tracking:** "Create a Notion-style template or Markdown checklist to track progress."
6. **Bonus:** "Generate a 'Week 1 Project' starter repo structure based on one of the roadmap items."

**Pro Tips:**
- This is excellent for long-horizon planning with the agent.
- Expected Outcome: A motivating, detailed 30-day plan tailored to you.

---

## Tutorial 10: Mini SaaS Starter Kit (Auth + Dashboard + Billing Mock)

**Goal:** Full-stack mini SaaS foundation.

**Detailed Sample Prompt:**
> Build a complete mini SaaS starter kit with: fake user authentication (register/login with JWT), responsive dashboard showing usage metrics and charts (using Chart.js or Recharts), settings page, mock billing/subscription page with Stripe-like UI, dark mode, beautiful Tailwind design system, and a small FastAPI backend. Structure it as a monorepo or clean full-stack project. Include fake data seeding and clear instructions on how to extend it into a real product.

**Step-by-Step Guiding Recipe:**

1. Paste prompt.
2. **Reply:** "Create the full project under `mini-saas/` with frontend and backend folders."
3. **Run it:** "Start both frontend and backend and show the dashboard working with sample data."
4. **Polish UI:** "Improve the design system and add responsive mobile navigation."
5. **Add feature:** "Implement a simple 'Usage-based billing' simulation that updates the dashboard live."
6. **Productionize:** "Add environment variables, basic rate limiting, and a README with 'How to turn this into a real SaaS' guide."

**Pro Tips:**
- Great template you can fork for real side projects.
- Expected Outcome: A beautiful, functional mini-SaaS you can build upon immediately.

---

## Tutorial 11: Browser Automation with Playwright

**Goal:** Reliable web automation & scraping scripts.

**Detailed Sample Prompt:**
> Create a robust, production-grade Python automation framework using Playwright. The script should: support both headless and headed modes via CLI, handle login flows on demo sites (e.g. demoqa.com or the-internet.herokuapp.com), take full-page and element screenshots with timestamps, extract structured data into clean JSON/CSV/Parquet, include automatic retries with exponential backoff, comprehensive logging, and error screenshots on failure. Provide requirements.txt, installation instructions for browsers, and example usage for 3 different tasks (form filling, data extraction, screenshot automation).

**Step-by-Step Guiding Recipe:**

1. Paste prompt.
2. **Reply:** "Create `browser-automation/` folder with `main.py`, `tasks/`, `utils/`, requirements.txt."
3. **Test one task:** "Run the data extraction task on a public demo site and show the JSON output + screenshots."
4. **Debug:** Paste any errors and ask for fixes.
5. **Enhance:** "Add stealth mode (undetected-playwright) and proxy support."
6. **Scale:** "Turn it into a small framework where I can define new tasks in YAML/JSON config files."

**Pro Tips:**
- Excellent for repetitive web tasks.
- Expected Outcome: A reusable automation toolkit.

---

## Tutorial 12: Local Image Generation + Voice Narration Pipeline

**Goal:** Multimodal content creation (image + audio).

**Detailed Sample Prompt:**
> Build a complete local multimodal pipeline that: (1) Generates high-quality images from text prompts using `diffusers` (Stable Diffusion 1.5 or a fast Lightning model) with GPU acceleration, (2) Generates a short creative story or detailed description of the image, (3) Converts the story into natural-sounding speech using a local TTS library (edge-tts, pyttsx3, or Piper), (4) Combines everything into a beautiful self-contained HTML viewer with image gallery + audio player. Support batch generation of 3-5 variations. Provide full code, requirements.txt, and clear instructions for running with GPU.

**Step-by-Step Guiding Recipe:**

1. Paste prompt.
2. **Reply:** "Create `multimodal-pipeline/` with `generate.py`, `viewer.html` template, and requirements."
3. **Test:** "Generate one image + narration. Show the HTML viewer working."
4. **Improve quality:** "Add negative prompts, better sampler settings, and upscaling."
5. **Advanced:** "Add image-to-image editing capability and a simple video export using moviepy (image + audio)."
6. **UI:** "Create a Gradio or Streamlit web interface for easier prompting."

**Pro Tips:**
- Requires decent GPU for good speed (use the GPU-enabled compose).
- Expected Outcome: A fun creative tool for generating illustrated stories with voiceover.

---

## Tutorial 13: Voice-Enabled AI Assistant (STT + TTS Continuous Chat)

**Goal:** Hands-free voice conversation with the local model.

**Detailed Sample Prompt:**
> Create a voice-enabled conversational assistant that runs locally: Use `speech_recognition` + Whisper (or faster-whisper) for Speech-to-Text, send transcribed text to Ollama (via the agent or direct API), get the response, and speak it back using a high-quality local TTS (edge-tts or Coqui). Make it a continuous loop with wake word detection ("Hey Assistant"), graceful interruption, conversation history, and a simple terminal or web UI. Include installation instructions and performance tips for real-time use.

**Step-by-Step Guiding Recipe:**

1. Paste prompt.
2. **Reply:** "Create `voice-assistant/` with `assistant.py` and all dependencies documented."
3. **Test basic loop:** "Run a short conversation and show transcription + response + TTS working."
4. **Improve UX:** "Add wake word, better VAD (voice activity detection), and streaming TTS if possible."
5. **Integrate with Agent Zero:** "Make it call the Agent Zero API so the assistant has full tool access."
6. **Polish:** "Create a nice web UI with microphone button using Gradio or FastAPI + WebSockets."

**Pro Tips:**
- Start with edge-tts for quality/speed balance.
- Expected Outcome: A fully functional voice chatbot you can talk to.

---

## Tutorial 14: Intelligent Code Refactoring & Documentation Agent

**Goal:** Automatically improve existing codebases.

**Detailed Sample Prompt:**
> Build an intelligent code refactoring assistant. The tool should: scan a project folder, analyze code quality (complexity, duplication, style), suggest and apply improvements (using AST or LLM-guided edits), generate comprehensive docstrings and type hints, create or update README and architecture diagrams (using mermaid or plantuml), and produce a before/after diff report. Support multiple languages (focus on Python first). Make it safe with dry-run mode and git integration.

**Step-by-Step Guiding Recipe:**

1. Paste prompt.
2. **Reply:** "Create `code-refactor-agent/` with the main script and supporting modules."
3. **Test on a small project:** "Point it at a sample messy Python folder and show the analysis + proposed changes."
4. **Apply changes:** "Apply the safe refactors and show the git diff."
5. **Enhance:** "Add support for generating unit tests for refactored functions."
6. **Report:** "Generate a beautiful Markdown report with metrics and recommendations."

**Pro Tips:**
- Extremely powerful when combined with the agent’s ability to run commands and edit files.
- Expected Outcome: A powerful code improvement toolkit.

---

## Tutorial 15: Automated Meeting Notes Processor & Action Item Generator

**Goal:** Turn raw transcripts into actionable intelligence.

**Detailed Sample Prompt:**
> Create a powerful meeting notes processor. Given a raw transcript (text file or pasted), the tool should: clean and segment the transcript, identify speakers if possible, extract key decisions, action items with owners and deadlines, generate a professional summary, create a structured Markdown report, suggest follow-up questions, and optionally generate calendar events or task list in JSON. Use local LLM for high-quality summarization and extraction. Provide a CLI + optional web interface.

**Step-by-Step Guiding Recipe:**

1. Paste prompt.
2. **Reply:** "Create `meeting-processor/` with `process_meeting.py`, templates, and example transcript."
3. **Test:** "Process the provided sample transcript and show the generated report."
4. **Improve extraction:** "Make action item extraction more accurate with better prompting and validation."
5. **Integrate:** "Add export to Notion, Todoist, or Google Tasks format."
6. **UI:** "Build a simple drag-and-drop web interface (Gradio or Streamlit) for uploading transcripts."

**Pro Tips:**
- Combine with voice assistant (Tutorial 13) for end-to-end meeting intelligence.
- Expected Outcome: A professional meeting intelligence tool that saves hours every week.

---

**How to Use These Tutorials Effectively**

1. Start with the **Step-by-Step Guiding Recipe** — follow the exact reply sequence.
2. Be patient and iterative — Agent Zero shines when given feedback.
3. Use commands like:
   - "Save this as `folder/file.ext`"
   - "Now run it and show me the output"
   - "Fix this error: [paste error]"
   - "Add this feature and update all files"
   - "Create a README.md and docker-compose.yml for this project"
4. Leverage the mounted volume — files created by the agent are accessible on your host.

Feel free to contribute new tutorials or improvements back to the repository!

**Happy building with your local AI agent!** 🚀
