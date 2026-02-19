# kai ui

Cyberpunk web IDE for the [kai](https://github.com/tcanaud/kai) governance stack.

## Quick Start

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

## Stack

- **Next.js 16** + React 19
- **Tailwind CSS 4** + Radix UI + shadcn/ui
- **TypeScript 5**

## Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start dev server |
| `npm run build` | Production build |
| `npm run start` | Serve production build |
| `npm run lint` | Run ESLint |

## Governance

This project runs the full **kai governance stack**:

```
.adr/          Architecture Decision Records
.agreements/   Feature agreements (contracts between product & code)
.features/     Feature lifecycle tracking
.knowledge/    Guides and project knowledge base
.playbooks/    Automated workflow playbooks
.product/      Feedbacks, backlogs, and product management
.qa/           Test plans and verdicts
```

### Playbooks

Automated workflows executed via `/playbook.run <name>`:

| Playbook | Steps | Description |
|----------|-------|-------------|
| `auto-feature` | 8 | Full feature workflow from plan to PR |
| `auto-validate` | 2 | QA validation: plan and run |
| `hotfix` | 6 | Fast-track critical bugs — skip full spec cycle |
| `intention-to-pr` | 12 | End-to-end from product intention to PR |
| `intention-to-pr-haiku` | 12 | Same as above, all steps with haiku model |
| `knowledge-maintenance` | 3 | Refresh index, check freshness, intake stale guides |
| `pm-digest` | 6 | Full PM pipeline: triage feedbacks, promote to features |
| `qa-mcp-chrome` | 10 | Adversarial QA via MCP Chrome DevTools |

### QA with MCP Chrome

This project includes a Chrome DevTools MCP server for browser-based QA testing. See the [QA guide](.knowledge/guides/qa-testing-mcp-chrome.md) for setup and usage.

## License

MIT
