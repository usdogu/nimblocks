import strutils, times, os, strformat
import x11/[xlib]
import ./utils, ./objects

const
    delim = " | "
    shell = "sh"
    cmdstropt = "-c"
    interval: Duration = initDuration(seconds = 3)


var blocks: seq[Block] = @[
  initBlock("\"free -h\" | awk '/^Mem:/ {print $3}' | sed 's/..$//'", true),
  initBlock(r"date '+%H:%M'", false)
]
var outputsSeq: seq[string] = @[]


proc main(): void =
    let (conn, root) = setupX()
    defer: discard conn.XCloseDisplay()

    for item in blocks.mitems:
        if item.inSh:
            item.cmd = fmt"{shell} {cmdstropt} {item.cmd}"

    while true:
        for item in blocks:
            item.run(outputsSeq)
        var final = ""
        for item in 0..blocks.high:
            final.add(delim)
            final.add(outputsSeq[item])
        final = final.strip.trimPrefix(delim)
        when not defined(release):
            echo final
        conn.setStatus(root, final)
        final.reset()
        outputsSeq.reset()
        sleep(inMilliseconds(interval).int)

main()
