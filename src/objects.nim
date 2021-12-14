import osproc, strutils

type Block* = object
    cmd*: string
    inSh*: bool
proc initBlock*(cmd: string, inSh: bool): Block =
    result = Block(cmd: cmd, inSh: inSh)

proc run*(self: Block, outputsSeq: var seq[string]): void =
    let output = execProcess(self.cmd)
    outputsSeq.add(output.splitLines()[0].strip())
