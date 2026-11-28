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

The report period runs from the 29th of the previous month through the 28th
of {month}, inclusive (the report is due on the last day of {month}). For
example, if {month} is 2025-12, the period is 2025-11-29 through 2025-12-28.

**For Git repositories** (all paths after the previous report path):

- Run
  `git -C <repo> log --since="<previous-month>-29" --until="{month}-29" --pretty=format:"%h - %s (%an)" --no-merges`
- Collect commit statistics and notable changes

**For Jira**:

- Run
  `jira issue list --updated-after '<previous-month>-29' --updated-before '{month}-29' --assignee 'Jaren Glenn' --raw`
  (Calculate the previous month for the after date, e.g., if month is
  2025-12, use 2025-11-29; roll over the year when {month} is January)
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
- Include 3-8 items per project section
- Each item should be 1-3 sentences describing the work and its value
- Use plain text only — no markdown, no bullet characters, no bold/italic
- Format: plain section name on its own line, followed by plain paragraph lines
- Write the report directly to a file so it can be copy-pasted into Outlook
  without formatting artifacts
