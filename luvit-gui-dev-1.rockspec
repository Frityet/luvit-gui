---@diagnostic disable: lowercase-global
rockspec_format = "3.0"
package = "luvit-gui"
version = "dev-1"
source = {
   url = "*** please add URL for source tarball, zip or repository here ***"
}
description = {
   homepage = "*** please enter a project homepage ***",
   license = "GPLv3"
}
dependencies = {
   "lua ~> 5.1",
   "luayue 0.14.0-bin"
}
build_dependencies = {
   "luarocks-build-extended"
}
build = {
   type = "extended",
   modules = {
      ["utilities"] = "utilities.cpp"
   }
}
