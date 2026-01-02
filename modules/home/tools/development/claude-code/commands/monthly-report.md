---
description: Generate monthly report using previous reports as template
argument-hint: [YYYY-MM] [previous-report-path] [repo-paths...]
---

Generate a monthly activity report for {month}.

First, read the previous report at the path provided in the second argument to
understand:

- The report structure and format
- The tone and level of detail
- What sections are included
- How data is presented and summarized

Then gather new data:

**For Git repositories** (all paths after the previous report path):

- Run
  `git -C <repo> log --since="{month}-01" --until="{month}-31" --pretty=format:"%h - %s (%an)" --no-merges`
- Collect commit statistics and notable changes

**For Jira**:

- Run
  `jira issue list --updated-after '{month}-01' --updated-before '<next-month>-01' --assignee 'Jaren Glenn' --raw`
  (Calculate next month for the before date, e.g., if month is 2025-12, use
  2026-01-01)
- Get issue details, statuses, and types

**Generate the new report** following the EXACT structure, tone, and format of
the previous report. Match:

- Section headings and organization
- Level of technical detail
- Summary style
- Any metrics or KPIs included
- Formatting conventions

**Verbosity and Format Requirements:**

- Focus on major improvements and features, not individual commits
- For each item, explain WHAT was done and WHY it matters to the user/customer
- Include 3-8 bullet points per project section
- Each bullet should be 1-3 sentences describing the work and its value
- Use bullet points with • characters (not indentation or dashes) for email
  compatibility
- Format as: **Project Name** • Bullet point describing work and why it matters
  • Another bullet point
- Ensure the output is copy-pastable directly into an email
