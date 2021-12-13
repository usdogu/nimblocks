import x11/[xlib, x]

proc setupX*(): (PDisplay, Window) =
    let dpy = XOpenDisplay(nil)
    if dpy == nil:
        quit("Can't open display", 1)
    (dpy, dpy.XRootWindow(dpy.XDefaultScreen))

proc setStatus*(display: PDisplay, root: Window, str: string): void =
    discard display.XStoreName(root, str.cstring)
    discard display.XSync(false.XBool)

proc trimPrefix*(str, prefix: string): string =
    result = str[prefix.len-1..^1]
