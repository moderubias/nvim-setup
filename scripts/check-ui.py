import logging
import os
import time
import tempfile
from pathlib import Path

import pynvim

logging.disable(logging.CRITICAL)
os.environ.pop("WAYLAND_DISPLAY", None)
os.environ.pop("DISPLAY", None)
root = Path(__file__).resolve().parents[1]
os.chdir(root)
provider = '''lua vim.g.test_clip = {"kept"}; vim.g.clipboard = {
name="test", copy={
["+"]=function(lines,kind) vim.g.test_clip=lines; vim.g.test_clip_type=kind end,
["*"]=function(lines,kind) vim.g.test_clip=lines; vim.g.test_clip_type=kind end},
paste={["+"]=function() return {vim.g.test_clip,vim.g.test_clip_type or "v"} end,
["*"]=function() return {vim.g.test_clip,vim.g.test_clip_type or "v"} end}, cache_enabled=0};
vim.opt.clipboard="unnamedplus"'''
nvim = pynvim.attach("child", argv=["nvim", "--embed", "-i", "NONE", "--cmd", provider])
nvim.ui_attach(160, 40, rgb=True)
failures = []
checks = 0


def check(name, fn):
    global checks
    checks += 1
    try:
        fn()
    except Exception as exc:
        failures.append(f"{name}: {exc}")


def settle():
    time.sleep(0.08)
    nvim.eval("1")


def screen():
    settle()
    return nvim.exec_lua("local s={}; for i=1,160 do s[#s+1]=vim.fn.screenstring(1,i) end; return table.concat(s)")


def registers():
    return nvim.exec_lua('local r={}; for _,k in ipairs({\'"\',"+","0","1","-"}) do r[k]=vim.fn.getreg(k) end; return r')


def prepare():
    nvim.command("enew!")
    nvim.exec_lua('vim.api.nvim_buf_set_lines(0,0,-1,false,{"alpha beta", "gamma delta", "last"}); vim.api.nvim_win_set_cursor(0,{1,0}); vim.fn.setreg(\'"\',"kept"); vim.fn.setreg("+","kept")')
    settle()


def deletion(keys):
    prepare()
    before = registers()
    nvim.input(keys)
    settle()
    assert registers() == before, f"{keys} changed paste registers"
    assert nvim.current.buffer[:] != ["alpha beta", "gamma delta", "last"], "text was not edited"


def copy_and_paste():
    prepare()
    nvim.input("yy")
    settle()
    assert "alpha beta" in nvim.funcs.getreg("+"), "y did not copy the selected text"
    nvim.input("jddp")
    settle()
    assert nvim.current.buffer[:] == ["alpha beta", "last", "alpha beta"], repr(nvim.current.buffer[:])


def repeat_and_named_register():
    prepare()
    before = registers()
    nvim.input("dd")
    settle()
    nvim.input(".")
    settle()
    assert nvim.current.buffer[:] == ["last"]
    assert registers() == before
    nvim.input("u")
    settle()
    assert nvim.current.buffer[:] == ["gamma delta", "last"]
    nvim.input('"add')
    settle()
    assert "gamma delta" in nvim.funcs.getreg("a")


def buffers():
    nvim.command("enew!")
    nvim.exec_lua('for _,b in ipairs(vim.api.nvim_list_bufs()) do if b~=vim.api.nvim_get_current_buf() then vim.api.nvim_buf_delete(b,{force=true}) end end')
    ids = nvim.exec_lua('local ids={}; for _,name in ipairs({"alpha.txt","beta.txt","gamma.txt"}) do local b=vim.api.nvim_create_buf(true,false); vim.api.nvim_buf_set_name(b,"/tmp/nvim-ui-"..name); ids[#ids+1]=b end; vim.api.nvim_set_current_buf(ids[3]); return ids')
    assert "alpha.txt" in screen()
    nvim.exec_lua('require("ui.buffers").close(...)', ids[0])
    assert "alpha.txt" not in screen(), "closed hidden buffer is still drawn"
    text = screen()
    column = text.index("", text.index("gamma.txt"))
    nvim.api.input_mouse("left", "press", "", 0, 0, column)
    nvim.api.input_mouse("left", "release", "", 0, 0, column)
    assert "gamma.txt" not in screen(), "mouse-closed buffer is still drawn"
    nvim.command("BufferLineCycleNext")
    settle()
    assert nvim.current.buffer.number not in (ids[0], ids[2])
    nvim.command(f"bdelete {ids[1]}")
    assert "beta.txt" not in screen(), ":bdelete left a ghost"
    stale = nvim.exec_lua('local ids={}; for _,e in ipairs(require("bufferline").get_elements().elements) do if not vim.api.nvim_buf_is_valid(e.id) or not vim.bo[e.id].buflisted then ids[#ids+1]=e.id end end; return ids')
    assert not stale, f"hidden panel retains deleted buffers: {stale}"
    nvim.exec_lua('local b=vim.api.nvim_create_buf(true,true); vim.bo[b].buftype="nofile"; vim.api.nvim_set_current_buf(b)')
    screen()
    nvim.exec_lua("return _G.nvim_bufferline()")
    assert nvim.options["showtabline"] == 0, "filtered utility buffer re-enabled the hidden tabline"


def quit_windows():
    nvim.command("enew!")
    nvim.command("tabnew /tmp/nvim-ui-quit.txt")
    buf = nvim.current.buffer.number
    nvim.command("q")
    settle()
    assert not nvim.funcs.buflisted(buf), ":q leaves the closed tab's buffer in the bar"
    with tempfile.TemporaryDirectory(prefix="nvim-quit-") as directory:
        for index, command in enumerate(("wq", "x", "normal ZZ")):
            path = Path(directory) / f"saved-{index}.txt"
            nvim.command("tabnew " + nvim.funcs.fnameescape(str(path)))
            saved = nvim.current.buffer.number
            nvim.current.buffer[:] = ["saved text"]
            nvim.command(command)
            settle()
            assert path.read_text() == "saved text\n", f"{command} did not save"
            assert not nvim.funcs.buflisted(saved), f"{command} left a ghost buffer"
    nvim.command("edit /tmp/nvim-ui-shared.txt")
    shared = nvim.current.buffer.number
    nvim.command("split")
    nvim.command("q")
    settle()
    assert nvim.funcs.buflisted(shared), "buffer still visible in another window was removed"
    nvim.command("tabnew /tmp/nvim-ui-unsaved.txt")
    dirty = nvim.current.buffer.number
    nvim.current.buffer[:] = ["unsaved text"]
    nvim.options["hidden"] = False
    nvim.options["confirm"] = False
    try:
        nvim.command("q")
    except pynvim.api.common.NvimError:
        pass
    settle()
    assert nvim.api.buf_is_valid(dirty) and nvim.api.buf_get_option(dirty, "modified"), "refused quit discarded edits"
    assert nvim.current.buffer.number == dirty, "refused quit closed the window"
    nvim.exec_lua('vim.v.errmsg=""')
    nvim.options["hidden"] = True
    nvim.options["confirm"] = True
    nvim.command("q!")
    settle()



def navigation_fixture():
    nvim.input("<Esc>")
    settle()
    nvim.command("enew!")
    nvim.exec_lua('for _,b in ipairs(vim.api.nvim_list_bufs()) do if b~=vim.api.nvim_get_current_buf() then vim.api.nvim_buf_delete(b,{force=true}) end end; vim.bo.buflisted=false')
    return nvim.exec_lua('local ids={}; for _,name in ipairs({"alpha","beta","gamma","delta"}) do local b=vim.api.nvim_create_buf(true,false); vim.api.nvim_buf_set_name(b,"/tmp/nvim-qa-nav/"..name..".txt"); ids[#ids+1]=b end; vim.api.nvim_set_current_buf(ids[1]); return ids')


def navigation_before_redraw():
    ids = navigation_fixture()
    # Change the live buffer list and press the mapped key in a single RPC call.
    # No UI redraw can update Bufferline's cached components between the two.
    actual = nvim.exec_lua('vim.api.nvim_set_current_buf(...); vim.cmd("normal L"); return vim.api.nvim_get_current_buf()', ids[2])
    assert actual == ids[3], f"next buffer before redraw: {actual}, expected {ids[3]}"
    for key, expected in (("L", ids[0]), ("H", ids[3]), ("H", ids[2])):
        nvim.input(key)
        settle()
        assert nvim.current.buffer.number == expected, f"{key}: got {nvim.current.buffer.number}, expected {expected}"


def newly_opened_buffer_navigation():
    ids = navigation_fixture()
    settle()
    actual = nvim.exec_lua('local b=vim.api.nvim_create_buf(true,false); vim.api.nvim_buf_set_name(b,"/tmp/nvim-qa-nav/new.txt"); vim.api.nvim_set_current_buf(b); vim.cmd("normal L"); return vim.api.nvim_get_current_buf()')
    assert actual == ids[0], f"new buffer did not wrap to the first buffer: {actual}"


def mouse_selects_requested_buffer():
    ids = navigation_fixture()
    for index, name in ((2, "gamma"), (0, "alpha"), (3, "delta"), (1, "beta")):
        text = screen()
        column = text.index(name + ".txt") + 1
        nvim.api.input_mouse("left", "press", "", 0, 0, column)
        nvim.api.input_mouse("left", "release", "", 0, 0, column)
        settle()
        assert nvim.current.buffer.number == ids[index], f"click on {name} selected another buffer"


def closing_selects_neighbour():
    ids = navigation_fixture()
    nvim.api.set_current_buf(ids[3])
    nvim.api.set_current_buf(ids[1])
    settle()
    nvim.exec_lua('require("ui.buffers").close()')
    settle()
    assert nvim.current.buffer.number == ids[2], "closing a buffer jumped to a distant alternate buffer"


def start_snippet():
    nvim.input("<Esc>")
    settle()
    nvim.command("enew!")
    nvim.command("setfiletype text")
    nvim.current.buffer[:] = ["", "", "outside"]
    nvim.current.window.cursor = (1, 0)
    nvim.input("i")
    settle()
    nvim.exec_lua('require("luasnip").lsp_expand("first ${1:one} then ${2:two}$0")')
    settle()


def tab_outside_snippet():
    start_snippet()
    nvim.input("value")
    settle()
    nvim.current.window.cursor = (3, len(nvim.current.buffer[2]))
    nvim.input("<Tab>")
    settle()
    assert nvim.current.window.cursor[0] == 3, "Tab jumped back into a snippet on another line"
    assert nvim.current.buffer[2].startswith("outside "), repr(nvim.current.buffer[:])
    nvim.input("<Esc>")
    settle()


def tab_past_snippet_on_same_line():
    start_snippet()
    nvim.input("<Esc>")
    settle()
    nvim.current.window.cursor = (1, len(nvim.current.buffer[0]))
    nvim.input("A trailing")
    settle()
    before = nvim.current.window.cursor
    nvim.input("<Tab>")
    settle()
    assert nvim.current.window.cursor[1] > before[1], "Tab jumped backwards to an old placeholder on the same line"
    nvim.input("<Esc>")
    settle()


def snippet_forward_backward():
    start_snippet()
    nvim.input("alpha<Tab>beta<S-Tab>gamma")
    settle()
    assert "gamma" in nvim.current.buffer[0] and "beta" in nvim.current.buffer[0], repr(nvim.current.buffer[:])
    nvim.input("<Esc>")
    settle()


def plain_indentation():
    nvim.input("<Esc>")
    settle()
    nvim.command("enew!")
    nvim.command("setfiletype text")
    nvim.command("setlocal expandtab tabstop=4 softtabstop=4 shiftwidth=4")
    nvim.current.buffer[:] = ["", "next"]
    nvim.input("i<Tab>hello<Tab>world")
    settle()
    assert nvim.current.buffer[0] == "    hello   world", repr(nvim.current.buffer[:])
    assert nvim.current.window.cursor[0] == 1
    nvim.input("<Esc>")
    settle()


def tabpages_and_buffer_navigation():
    ids = navigation_fixture()
    original = nvim.current.tabpage.handle
    nvim.command("tabnew /tmp/nvim-qa-tabpage.txt")
    other = nvim.current.tabpage.handle
    nvim.input("gT")
    settle()
    assert nvim.current.tabpage.handle == original
    nvim.input("gt")
    settle()
    assert nvim.current.tabpage.handle == other
    nvim.api.set_current_buf(ids[1])
    nvim.input("L")
    settle()
    assert nvim.current.tabpage.handle == other, "buffer navigation switched the tabpage"
    assert nvim.current.buffer.number == ids[2]
    nvim.command("tabclose!")
    settle()
    assert nvim.current.tabpage.handle == original


def snippet_deletion_and_buffer_switch():
    start_snippet()
    nvim.input("<Esc>")
    settle()
    source = nvim.current.buffer.number
    nvim.command("enew!")
    nvim.input("i<Tab>other")
    settle()
    assert nvim.current.buffer.number != source
    assert nvim.current.buffer[0].lstrip() == "other"
    assert nvim.current.window.cursor[0] == 1
    nvim.input("<Esc>")
    settle()
    nvim.api.set_current_buf(source)
    nvim.current.buffer[:] = ["removed", "current"]
    nvim.current.window.cursor = (2, 0)
    nvim.input("A<Tab>")
    settle()
    assert nvim.current.window.cursor[0] == 2, "deleted snippet retained an active jump target"
    nvim.input("<Esc>")
    settle()


def rust_completion_provider():
    nvim.command("enew!")
    nvim.command("setfiletype rust")
    nvim.current.buffer[:] = ["#[derive(Debug, Cl"]
    nvim.current.window.cursor = (1, len(nvim.current.buffer[0]) - 1)
    labels = nvim.exec_lua('local cfg=require("blink.cmp.config"); local source=require(cfg.sources.providers.rust_derive.module).new(); local labels={}; source:get_completions({bufnr=vim.api.nvim_get_current_buf()}, function(result) for _,item in ipairs(result.items) do labels[#labels+1]=item.label end end); return labels')
    assert "Clone" in labels, labels
    assert "Debug" not in labels, "existing derive was suggested again"
    nvim.current.buffer.options["modified"] = False


def no_async_errors():
    settle()
    errors = nvim.vars.get("qa_errors", [])
    assert not errors, "\n".join(errors)
    # LuaSnip uses silent! foldopen! when selecting a field. With no fold,
    # Neovim stores E490 in v:errmsg without displaying or raising an error.
    assert nvim.vvars["errmsg"] in ("", "E490: No fold found"), nvim.vvars["errmsg"]


def markdown_appearance():
    nvim.command("enew!")
    nvim.current.buffer[:] = ["# Preview check", "", "```bash", "./launch.sh check", "```", ""] + ["Plain Unicode text: café, naïve, λ."] * 12
    nvim.command("setfiletype markdown")
    nvim.current.window.cursor = (15, 0)
    time.sleep(0.5)
    settle()
    assert not nvim.current.window.options["spell"], "Spell checking is unexpectedly enabled for prose"
    marks = nvim.exec_lua('local ns=vim.api.nvim_get_namespaces()["render-markdown.nvim"]; return vim.api.nvim_buf_get_extmarks(0,ns,0,-1,{details=true})')
    assert marks, "Markdown did not render"
    for mark in marks:
        for chunk in mark[3].get("virt_text", []):
            assert "█" not in chunk[0], "solid header stripe remains"
    for reload in (False, True):
        if reload:
            nvim.command("colorscheme stemdark")
            settle()
        for group in ("RenderMarkdownCode", "RenderMarkdownCodeBorder", "RenderMarkdownCodeInline"):
            highlight = nvim.api.get_hl(0, {"name": group, "link": False})
            assert highlight.get("bg", 0) < 0x404040, f"bright {group}: {highlight}"
    nvim.current.buffer.options["modified"] = False



try:
    settle()
    nvim.exec_lua('vim.g.qa_errors={}; local notify=vim.notify; vim.notify=function(message,level,opts) if level==vim.log.levels.ERROR then local errors=vim.g.qa_errors; errors[#errors+1]=tostring(message); vim.g.qa_errors=errors end; return notify(message,level,opts) end')
    for keys in ("dd", "dw", "2dd", "D", "x", "X", "cwreplacement<Esc>", "Cnew<Esc>", "vld", "Vd"):
        check(f"Registers preserved: {keys}", lambda keys=keys: deletion("lX" if keys == "X" else keys))
    check("Copy, delete and paste", copy_and_paste)
    check("Repeat, undo and named register", repeat_and_named_register)
    check("Bufferline redraw, mouse closing and cycling", buffers)
    check("Quit closes only unmodified hidden file buffers", quit_windows)
    check("Navigation before redraw and wraparound", navigation_before_redraw)
    check("New buffer navigation before the first redraw", newly_opened_buffer_navigation)
    check("Mouse selects exactly the requested buffer", mouse_selects_requested_buffer)
    check("Closing selects the adjacent buffer", closing_selects_neighbour)
    check("Tab outside a snippet stays on the current line", tab_outside_snippet)
    check("Tab after a snippet stays at the current column", tab_past_snippet_on_same_line)
    check("Snippet forward and backward navigation", snippet_forward_backward)
    check("Plain Tab inserts indentation", plain_indentation)
    check("Tabpages and buffer navigation stay independent", tabpages_and_buffer_navigation)
    check("Deleted snippets and buffer switches do not retain Tab jumps", snippet_deletion_and_buffer_switch)
    check("Rust derive completion loads its configured provider", rust_completion_provider)
    check("Markdown code blocks and optional spelling", markdown_appearance)
    check("No asynchronous configuration errors", no_async_errors)
finally:
    try:
        nvim.command("qa!")
    except (EOFError, OSError):
        pass

if failures:
    raise SystemExit("\n".join(failures))
print(f"PASS: {checks} interactive UI checks")
