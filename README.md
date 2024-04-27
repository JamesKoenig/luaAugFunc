
a lua library to wrap functions in a callable augmentation that provides some
useful operations as syntactic sugar.

Should any operation require the idea of success or failure (like filtration,
  sequencing, etc), the function is expected to return nil on failure, or any
    non-nil result on success.

N.B. your version of lua will only define the following operations:
Lua 5.1 (https://www.lua.org/manual/5.1/manual.html#2.8):
- (f .. g)
- (f * tableLike)
- (f ^ g)
Lua 5.3 (https://www.lua.org/manual/5.3/manual.html#2.4) defines the above
as well as:
- (f ~ tableLike)
- (f << tableLike)
- (f & g)
- (f | g)

If you are using a custom lua implementation it may choose not to implement the
  operations listed above.
  (ex. CC Tweaked's Cobalt fork of LuaJ,
    see https://tweaked.cc/reference/feature_compat.html)
