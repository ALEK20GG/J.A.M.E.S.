# Frontend — James (SvelteKit)

Questo è il posto per l'app SvelteKit.

Per inizializzare il progetto frontend (consigliato):

1. Installare Node.js e pnpm (o npm): https://nodejs.org/
2. Dalla root: `cd frontend` e inizializzare SvelteKit:
   - `pnpm create svelte@latest .` (seguire le opzioni desiderate)
3. Installare dipendenze: `pnpm install`
4. Avviare in dev: `pnpm dev`

Se `npm run dev` dà errore `Invalid command: dev`, prova uno di questi comandi alternativi (funzionano anche quando `npm`/`npx` non sono nel PATH):

- `node ./node_modules/@sveltejs/kit/svelte-kit.js dev`
- (PowerShell) `./scripts/run_dev.ps1` — script comodo che esegue la CLI locale

La `dev` script in `package.json` è stata aggiornata per chiamare la CLI locale in modo da migliorare l'affidabilità.

Nota: per ora c'è solo un semplice placeholder `src` con componenti base.
