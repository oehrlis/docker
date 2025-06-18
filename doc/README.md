# Folder: doc

This folder contains the **documentation** for the Oracle Docker Automation project. It serves as a central place for architectural notes, diagrams, usage guides, and technical explanations.

## Purpose

To document:

- The build and patching processes
- Folder and file structure
- Supported platforms and configurations
- Customization options and examples
- Internal tooling (e.g., AutoUpgrade wrapper scripts)

## Conventions

- Use [Markdown](https://www.markdownguide.org/basic-syntax/) for all documentation
- Store image assets in `images/`
- Include frontmatter headers if generating PDF/HTML via Pandoc
- Follow consistent filename patterns, e.g.:

  * `overview.md`, `patching.md`, `database_builds.md`, `upgrade_paths.md`

## PDF / HTML Generation (Optional)

If required, you can generate PDF or HTML from Markdown using [Pandoc](https://pandoc.org/):

```bash
pandoc doc/overview.md \
  --from markdown \
  --output artefacts/overview.pdf \
  --pdf-engine=xelatex \
  --template=default.latex \
  --variable mainfont="Graphik" \
  --resource-path=.:images:fonts
```
