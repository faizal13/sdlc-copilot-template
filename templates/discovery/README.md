# Discovery Folder

This folder is the **input source** for `@solution-architect`. Place all unstructured business and technical inputs here before running the agent.

## What to Put Here

| File Type | Examples | Purpose |
|-----------|----------|---------|
| Business Requirements | BRD.docx, requirements.md, user-stories.txt | Core business needs and processes |
| Epic Descriptions | epic-overview.md, pasted ADO epic text | Structured requirements from ADO |
| Regulatory / Compliance | cbuae-guidelines.pdf, pci-dss-scope.md | Regulatory constraints |
| Existing System Docs | current-architecture.md, legacy-api-specs.yaml | Understand what exists today |
| Wireframes / Mockups | screens.png, user-flow.svg, figma-export.pdf | UI/UX requirements |
| API Samples | sample-request.json, middleware-wsdl.xml | Integration contracts |
| Meeting Notes | kickoff-notes.md, stakeholder-interview.txt | Context from discussions |
| Data Dictionaries | data-model.xlsx, field-definitions.csv | Data structure requirements |
| Reference Material | competitor-analysis.md, vendor-docs.pdf | Industry context |

## Folder Structure (Optional)

You can organize files into subfolders for clarity:

```
discovery/
├── epics/                → ADO epic descriptions (pasted as text)
├── reference/            → Competitor analysis, vendor docs, reference architectures
├── regulatory/           → CBUAE guidelines, PCI-DSS scope, KYC/AML requirements
├── wireframes/           → UI mockups, screen flows
└── (root)                → Business requirements, meeting notes, data dictionaries
```

## How to Use

1. Place your files in this folder
2. Run: `@solution-architect` (or `@solution-architect EPIC-123` if you have an ADO epic)
3. The agent reads everything here and produces `docs/solution-design/`

## Rules

- **More input = better design.** The agent can only design what it knows about.
- **Don't worry about format.** The agent handles .md, .txt, .pdf, .docx, .json, .yaml, .xml, images.
- **Keep files focused.** One topic per file is easier to process than one giant document.
- **Update and re-run.** When new requirements come in, add files here and run `@solution-architect --update`.
