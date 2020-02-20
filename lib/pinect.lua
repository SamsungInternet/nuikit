local ffi = require("ffi")

ffi.cdef[[
    
  struct pinect_dev;
  typedef struct pinect_dev pinect_dev;

  pinect_dev *pinect_init(unsigned char *f);
  unsigned short * pinect_grab(pinect_dev *dev, int r);
  int pinect_free(void *dev);
]]

local lib = ffi.load("/usr/local/lib/libpinect.so")

local mt = {
  __index = {
    grab = lib.pinect_grab,
    attr = lib.pinect_attr 
  }
}

local conf = ffi.metatype("pinect_dev", mt)
return function(s) 
  return ffi.gc(lib.pinect_init(s),lib.pinect_free)
end
