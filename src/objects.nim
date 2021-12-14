import osproc, strformat, strutils

type Block* = object
    cmd*: string
    inSh*: bool
    args*: seq[string]
proc initBlock*(cmd: string, inSh: bool): Block =
    result = Block(cmd: cmd, inSh: inSh, args: @[])

proc run*(self: Block, outputsSeq: var seq[string]): void =
    let joined = self.args[1..^1].join(" ")
    let output = execProcess(fmt"{self.args[0]} {joined}")
    outputsSeq.add(output.splitLines()[0].strip())
