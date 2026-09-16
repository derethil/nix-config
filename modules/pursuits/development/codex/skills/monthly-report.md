---
name: monthly-report
description: Generate a monthly activity report using a previous report as the template and activity from Git repositories and Jira. Use when asked to generate a monthly report for a YYYY-MM period.
---

Generate a monthly activity report for the requested month.

## Inputs

The user should provide:

1. The month to report on, in `YYYY-MM` format.
2. The path to the previous report to use as the template.
3. One or more Git repository paths.

If these values are provided together in the user's request, interpret them in
that order.

Derive the first day of the month and the first day of the following month. Use
the following month as the exclusive upper bound for date queries. This avoids
assuming every month has 31 days.

## Previous report

First, read the previous report to understand:

- The report structure and format
- The tone and level of detail
- What sections are included
- How data is presented and summarized

The generated report must follow the previous report's structure, tone, and
format as closely as possible.

## Git activity

For every provided Git repository, gather commits for the requested month.

Run:

    git -C <repo> log \
      --since="<month>-01" \
      --until="<next-month>-01" \
      --pretty=format:"%h - %s (%an)" \
      --no-merges

Review the commits as a whole rather than treating each commit as a report item.

Collect:

- Major features and improvements
- Notable fixes
- Architectural or infrastructure changes
- User-visible changes
- Relevant commit statistics

Focus on meaningful outcomes rather than individual commits.

## Jira activity

Run:

    jira issue list \
      --updated-after '<month>-01' \
      --updated-before '<next-month>-01' \
      --assignee 'Jaren Glenn' \
      --raw

For example, for `2025-12`, use `2026-01-01` as the `--updated-before` value.

Inspect relevant issues as needed to determine:

- What work was completed
- Issue status
- Issue type
- Important context not apparent from the summary alone

Do not mechanically include every Jira issue. Use Jira activity together with
Git activity to identify the month's significant work.

## Generate the report

Generate the new report following the EXACT structure, tone, and format of the
previous report.

Match:

- Section headings and organization
- Level of technical detail
- Summary style
- Metrics or KPIs included
- Formatting conventions

Prefer grouping related commits and Jira issues into a single meaningful report
item.

For each item, explain both:

1. WHAT was done.
2. WHY it matters to the user or customer.

## Verbosity and format

- Focus on major improvements and features, not individual commits.
- Include 3-8 items per project section when enough meaningful activity exists.
- Each item should be 1-3 sentences describing the work and its value.
- Do not invent work, impact, metrics, or conclusions unsupported by the source
  material.
- Use plain text only.
- Do not use Markdown formatting.
- Do not use bullet characters.
- Do not use bold or italic formatting.
- Use a plain section name on its own line followed by plain paragraph lines.
- Preserve any formatting conventions from the previous report that are
  compatible with plain text.

## Output

Write the finished report directly to a file rather than only printing it in the
conversation.

If the user provides an output path, use it.

Otherwise, write the report alongside the previous report. If the previous
report's filename has an obvious month-based naming convention, preserve that
convention for the new month. Otherwise use:

    monthly-report-<YYYY-MM>.txt

The resulting file must be suitable for copy-pasting directly into Outlook
without Markdown or other formatting artifacts.

After writing the file, tell the user which file was created.
