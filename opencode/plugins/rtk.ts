import { execFileSync } from "node:child_process"

// RTK OpenCode plugin — rewrites commands to use rtk for token savings.
// Requires: rtk >= 0.23.0 in PATH. All rewrite logic lives in `rtk rewrite`.

const rewrite = (command: string): string | undefined => {
  try {
    const out = execFileSync("rtk", ["rewrite", command], {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    }).trim()
    return out && out !== command ? out : undefined
  } catch (error: any) {
    // rtk rewrite may exit non-zero while still printing a rewrite
    const out = String(error?.stdout ?? "").trim()
    return out && out !== command ? out : undefined
  }
}

const isShell = (tool: unknown) => ["bash", "shell"].includes(String(tool ?? "").toLowerCase())

export default {
  id: "rtk",
  async setup(ctx: any) {
    await ctx.tool.hook("execute.before", (event: any) => {
      if (!isShell(event.tool)) return
      const input = event.input
      if (!input || typeof input !== "object" || typeof input.command !== "string" || !input.command) return
      const rewritten = rewrite(input.command)
      if (rewritten) input.command = rewritten
    })
  },
}
