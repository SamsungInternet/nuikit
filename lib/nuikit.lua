local ffi = require("ffi")

ffi.cdef[[

typedef struct {
  unsigned int label, next, sum;
  struct {
    unsigned short pos, val;
  } row, left, right, near, far;
} nuikit_run;

typedef struct {
 unsigned int  count, runs, index, next;
} nuikit_label;


struct nuikit_conf;
typedef struct nuikit_conf nuikit_conf;

nuikit_conf* nuikit_init(void *fn, void *ud);
void nuikit_free(nuikit_conf *conf);

int nuikit_clip(nuikit_conf *conf, int xmin, int ymin, int xmax, int ymax, int zmin, int zmax);
int nuikit_attr(nuikit_conf *conf, const char *key, int value);
int nuikit_scan(nuikit_conf *conf, void *data);

nuikit_run* nuikit_runs(nuikit_conf *conf);
nuikit_label* nuikit_blobs(nuikit_conf *conf);

]]

local lib = ffi.load("/usr/local/lib/libnuikit.so")

local mt = {
  __index = {
	  clip = lib.nuikit_clip,
    attr = function(c, s, v) return lib.nuikit_attr(c,s,v ~= nil and v or -1) end,
    scan = lib.nuikit_scan,
    runs = lib.nuikit_runs,
	  blobs = lib.nuikit_blobs
  }
}

local conf = ffi.metatype("nuikit_conf", mt)

return function()
    return ffi.gc(lib.nuikit_init(nil,nil),lib.nuikit_free)
end


