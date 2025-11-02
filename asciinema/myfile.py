print("Welcome to this demo file!")

print("Run a file with F5")

print("It's just another toggleterm terminal")

print("Send to terminal with F9")

print("Pick your python environment")

print("Choose your terminal direction")

print("Let's debug something")

print("Use ipdab to connect ipdb/pdb to Neovim's debugger.")

print("It's wrapper around ipdab/pdb that starts a DAP server.")

print("Use next/continue/step in the terminal")

print("Or use shortcuts F5/F10/F11")

import ipdab

ipdab.set_trace()


def myfun():
    print("Let's put a breakpoint using nvim-dap")


print(myfun())

print("Happy coding!")
