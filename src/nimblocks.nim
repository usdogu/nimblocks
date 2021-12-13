import osproc, strformat, strutils, times, os
import x11/[xlib]
import ./utils

const
    delim = " | "
    shell = "sh"
    cmdstropt = "-c"
    interval: Duration = initDuration(seconds = 3)

type Block* = object
    cmd: string
    inSh: bool
    args: seq[string]
proc initBlock(cmd: string, inSh: bool): Block =
    result = Block(cmd: cmd, inSh: inSh, args: @[])
var blocks: seq[Block] = @[
  initBlock("\"free -h\" | awk '/^Mem:/ {print $3}' | sed 's/..$//'", true),
  initBlock(r"date '+%H:%M'", false)
]
var outputsSeq: seq[string] = @[]
proc run*(self: Block): void =
    let joined = self.args[1..^1].join(" ")
    let output = execProcess(fmt"{self.args[0]} {joined}")
    outputsSeq.add(output.splitLines()[0].strip())


proc main(): void =
    let (conn, root) = setupX()
    defer: discard conn.XCloseDisplay()

    for item in blocks.mitems:
        if item.inSh:
            item.args = @[shell, cmdstropt, item.cmd]
        else:
            item.args = item.cmd.split(" ")

    while true:
        for item in blocks:
            item.run()
        var final = ""
        for item in 0..blocks.high:
            final.add(delim)
            final.add(outputsSeq[item])
        final = final.strip.trimPrefix(delim)
        conn.setStatus(root, final)
        final.reset()
        outputsSeq.reset()
        sleep(inMilliseconds(interval).int)

main()
